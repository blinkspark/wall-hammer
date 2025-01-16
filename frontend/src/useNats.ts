import { wsconnect, type NatsConnection } from '@nats-io/nats-core'

let nc: NatsConnection | null = null

export async function useNats() {
  if (!nc) {
    nc = await wsconnect({ servers: 'ws://localhost:23223' })
  }
  return nc
}
