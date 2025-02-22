import asyncio
import json
import threading
import nats
from nats.aio.msg import Msg
from yt_dlp import YoutubeDL
import logging
import re

logging.basicConfig(level=logging.DEBUG, format="%(levelname)s - %(message)s")
EXTRACT_INFO_SERVICE = "neal.service.viddown.extract_info"
DOWNLOAD_SERVICE = "neal.service.viddown.download"
DOWNLOAD_TASK_CHANNEL = "neal.service.viddown.task"


async def main():

    nc = await nats.connect(
        servers=["tls://demo.nats.io:4443"],
    )

    await nc.subscribe(EXTRACT_INFO_SERVICE, cb=extract_info)
    await nc.subscribe(DOWNLOAD_SERVICE, cb=download)

    try:
        await asyncio.Future()
    except asyncio.CancelledError:
        pass
    await nc.close()


async def extract_info(msg: Msg):
    data = json.loads(msg.data.decode())
    logging.debug(f"extract_info {data}")
    if data["url"] == "":
        await msg.respond(json.dumps({"ok": False, "error": "url is empty"}).encode())
        return
    with YoutubeDL() as ydl:
        try:
            info = ydl.extract_info(data["url"], download=False)
            resp = {"ok": True, "data": info}
            with open("resp.json", "w", encoding="utf-8") as f:
                f.write(json.dumps(info, indent=2, ensure_ascii=False))
            await msg.respond(json.dumps(resp, ensure_ascii=False).encode())
        except Exception as e:
            logging.error(e)
            await msg.respond(
                json.dumps({"ok": False, "error": str(e)}, ensure_ascii=False).encode()
            )
    logging.debug("done")


async def download(msg: Msg):
    logging.debug("download")
    data = json.loads(msg.data.decode())
    logging.debug(f"data {data}")
    url = data["url"]
    format = data["format_id"]
    id = data["id"]
    await msg.respond(json.dumps({"ok": True}, ensure_ascii=False).encode())
    logging.debug(f"downloading {url} with format {format}")
    topic = f"neal.service.viddown.task_progress.{id}"
    logging.debug(f"topic {topic}")

    def progress_hook(d):
        # logging.debug(f"progress_hook {d}")
        percent: str = d["_percent_str"]
        logging.debug(f"progress: {d['_percent_str']}")
        progress = re.findall(r"-?\d+\.?\d*%", percent)[0]
        logging.debug(f"progress re: {progress}")
        progress = round(float(progress[:-1]) / 100.0, 2)
        if d["status"] == "downloading":
            logging.debug(f"status: {d['status']}")

            async def publish():
                logging.debug(f"publishing {progress}")
                await msg._client.publish(
                    topic,
                    json.dumps(
                        {
                            "ok": True,
                            "progress": progress,
                        }
                    ).encode(),
                )
                logging.debug(f"published")

            def tread_run(task):
                loop = asyncio.new_event_loop()
                loop.run_until_complete(task())
                loop.close()

            thread = threading.Thread(target=tread_run, args=(publish,))
            thread.start()
            thread.join()

    with YoutubeDL(
        {
            "format": format,
            "progress_hooks": [progress_hook],
        }
    ) as ydl:
        try:
            ydl.download([url])
            logging.debug("downloaded!!")
            await msg._client.publish(
                topic,
                json.dumps({"ok": True, "progress": 1.0}).encode(),
            )
        except Exception as e:
            await msg._client.publish(
                topic,
                json.dumps({"ok": False, "error": str(e)}).encode(),
            )
            logging.error(e)


if __name__ == "__main__":
    asyncio.run(main())
