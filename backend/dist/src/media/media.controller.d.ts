export declare class MediaController {
    getToken(body: {
        channel: string;
    }): {
        token: string;
        channel: string;
        expiresAt: number;
    };
}
