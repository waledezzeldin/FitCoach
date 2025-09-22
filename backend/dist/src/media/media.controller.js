"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediaController = void 0;
const common_1 = require("@nestjs/common");
const agora_access_token_1 = require("agora-access-token");
let MediaController = class MediaController {
    getToken(body) {
        const appId = process.env.AGORA_APP_ID;
        const appCert = process.env.AGORA_APP_CERT;
        const channel = body.channel;
        const uid = 0;
        const expire = Math.floor(Date.now() / 1000) + 3600;
        const token = agora_access_token_1.RtcTokenBuilder.buildTokenWithUid(appId, appCert, channel, uid, agora_access_token_1.RtcRole.PUBLISHER, expire);
        return { token, channel, expiresAt: expire };
    }
};
exports.MediaController = MediaController;
__decorate([
    (0, common_1.Post)('token'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], MediaController.prototype, "getToken", null);
exports.MediaController = MediaController = __decorate([
    (0, common_1.Controller)('media')
], MediaController);
//# sourceMappingURL=media.controller.js.map