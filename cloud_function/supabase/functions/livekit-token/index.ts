import { AccessToken } from "npm:livekit-server-sdk"
import "jsr:@std/dotenv/load"

Deno.serve(async (req) => {
  const apiKey = Deno.env.get("LIVEKIT_API_KEY")
  const apiSecret = Deno.env.get("LIVEKIT_API_SECRET")
  const { room, participant } = await req.json()
  const livekit = new AccessToken(apiKey, apiSecret,{
    identity: participant,
    ttl: "1h",
  })
  livekit.addGrant({
    roomJoin: true,
    room: room,
  })
  const data = {
    token: await livekit.toJwt(),
  }

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})
