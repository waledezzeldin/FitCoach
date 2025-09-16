import { Controller, Post, Body } from '@nestjs/common';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';


@Controller('media')
export class MediaController {
@Post('token')
getToken(@Body() body: { channel: string }) {
const appId = process.env.AGORA_APP_ID!;
const appCert = process.env.AGORA_APP_CERT!;
const channel = body.channel;
const uid = 0; // use 0 for uid or server-generated
const expire = Math.floor(Date.now()/1000) + 3600;
const token = RtcTokenBuilder.buildTokenWithUid(appId, appCert, channel, uid, RtcRole.PUBLISHER, expire);
return { token, channel, expiresAt: expire };
}
}