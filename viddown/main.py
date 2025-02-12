import asyncio
import json
import nats
from nats.aio.msg import Msg
from yt_dlp import YoutubeDL


async def main():

    nc = await nats.connect(
        servers=["tls://demo.nats.io:4443"],
    )

    async def cb(msg: Msg):
        data = json.loads(msg.data.decode())
        print(data)
        if data['url'] == '':
            await msg.respond(json.dumps({"ok": False, "error": "url is empty"}).encode())
            return
        with YoutubeDL() as ydl:
            try:
                info = ydl.extract_info(data["url"], download=False)
                resp = {"ok": True, "data": info}
                await msg.respond(json.dumps(resp, ensure_ascii=False).encode())
            except Exception as e:
                print("exception:", e)
                await msg.respond(
                    json.dumps(
                        {"ok": False, "error": str(e)}, ensure_ascii=False
                    ).encode()
                )
        print("done")
        #     # print(info)

    await nc.subscribe("neal.service.viddown.extract_info", cb=cb)

    try:
        await asyncio.Future()
    except asyncio.CancelledError:
        pass
    await nc.close()


if __name__ == "__main__":
    asyncio.run(main())
