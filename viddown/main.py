import asyncio
import json
import nats
from nats.aio.msg import Msg
from yt_dlp import YoutubeDL


async def main():

    nc = await nats.connect(
        servers=["tls://demo.nats.io:4443"],
    )

    await nc.subscribe("neal.service.viddown.extract_info", cb=extract_info)
    await nc.subscribe("neal.service.viddown.download", cb=download)

    try:
        await asyncio.Future()
    except asyncio.CancelledError:
        pass
    await nc.close()


async def extract_info(msg: Msg):
    data = json.loads(msg.data.decode())
    print(data)
    if data["url"] == "":
        await msg.respond(json.dumps({"ok": False, "error": "url is empty"}).encode())
        return
    with YoutubeDL() as ydl:
        try:
            info = ydl.extract_info(data["url"], download=False)
            resp = {"ok": True, "data": info}
            with open("resp.json", "w") as f:
                f.write(json.dumps(info, indent=2, ensure_ascii=False))
            await msg.respond(json.dumps(resp, ensure_ascii=False).encode())
        except Exception as e:
            print("exception:", e)
            await msg.respond(
                json.dumps({"ok": False, "error": str(e)}, ensure_ascii=False).encode()
            )
    print("done")

async def download(msg: Msg):
    print("download")
    data = json.loads(msg.data.decode())
    print(data)

if __name__ == "__main__":
    asyncio.run(main())
