public class HEAT_ClientCredentialAuthProvider extends Auth.AuthProviderPluginClass {

    public static final String CUSTOM_METADATA_TYPE = 'BasicCustomClientCredentialAuthProvider__mdt';
    public static final String AUTH_PROVIDER_NAME = 'HEAT Client Credentials Auth Provider';

    // declarations
    private IRefreshTokenGenerator generator = new DefaultRefreshTokenGenerator();

    public HEAT_ClientCredentialAuthProvider() {
    }
    public HEAT_ClientCredentialAuthProvider(IRefreshTokenGenerator gen) {
        this.generator = gen;
    }

    public String getCustomMetadataType() {
        return CUSTOM_METADATA_TYPE;
    }

    public PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        final String url = authProviderConfiguration.get('Callback_URL__c') + '?state=' + stateToPropagate;
        return new PageReference(url);
    }

    public Auth.AuthProviderTokenResponse handleCallback(
        Map<String, String> config,
        Auth.AuthProviderCallbackState callbackState
    ) {
        // get access token
        final String access_token = this.retrieveToken(config);
        final String refresh_token = this.generateRefreshToken();
        final String state = callbackState.queryParameters.get('state');
        return new Auth.AuthProviderTokenResponse(AUTH_PROVIDER_NAME, access_token, refresh_token, state);
    }

    public Auth.UserData getUserInfo(
        Map<String, String> authProviderConfiguration,
        Auth.AuthProviderTokenResponse response
    ) {
        
        String message = 'Client Credentials';
        return new Auth.UserData(
            null,
            null,
            null,
            null,
            null,
            null,
            message, // Appears in the Named Credentials Authorizaition Status after "Authorized as..."
            null,
            AUTH_PROVIDER_NAME, 
            null,
            new Map<String, String>()
        );
    }

    public override Auth.OAuthRefreshResult refresh(Map<String, String> config, String refreshToken) {
        // generate dummy refresh token and get new access token
        final String newRefreshToken = this.generateRefreshToken();
        final String access_token = this.retrieveToken(config);
        return new Auth.OAuthRefreshResult(access_token, newRefreshToken);
    }

    private class AccessTokenRequest {
        public String grant_type;
        public String client_id;
        public String client_secret;
        public String scope;
    }

    private String retrieveToken(Map<String, String> config) {
        AccessTokenRequest tokenRequest = new AccessTokenRequest();
		String payload = 'client_id=' + config.get('Client_Id__c') + '&client_secret=' 
        + config.get('Client_Secret__c') + '&scope=' + config.get('Scope__c')+ '&grant_type=client_credentials';

        final String tokenEndpoint = config.get('Token_URL__c');

        final String body = JSON.serialize(tokenRequest);

        // setup request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpoint);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('Content-Length', String.valueOf(payload.Length()));
        req.setMethod('POST');
        req.setBody(payload);

        // execute requets
        Http h = new Http();
        HttpResponse res = h.send(req);

        // get token from response
        return this.getTokenFromHttpResponse(res);
    }
    private class AccessToken {
		public string access_token;
		public integer expires_in;
		public string token_type;
    }

    /**
     * Get the access_token from Http response.
     *
     */
    private String getTokenFromHttpResponse(HttpResponse res) {

        if(res.getStatusCode() == 200){
            final AccessToken token = (AccessToken) JSON.deserialize(res.getBody(), AccessToken.class);
            system.debug(token.expires_in);
            system.debug(token.token_type);
            return token.access_token;
        }
        else {
            System.debug(res.getStatusCode());
            System.debug(res.getBody());
            throw new CustomAuthProviderException(res.getStatusCode() + ' : ' + res.getBody());
        }
    }

    private String generateRefreshToken() {
        return this.generator.generate();
    }

    public class CustomAuthProviderException extends Exception {
        public String error;
        public String error_uri;
        public String error_description;
    }

    /**
     * Interface to allow us to override refresh token generation when testing.
     */
    public interface IRefreshTokenGenerator {
        String generate();
    }

    /**
     * Default implementation for runtime.
     */
    public class DefaultRefreshTokenGenerator implements IRefreshTokenGenerator {
        public String generate() {
            final String refreshToken = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
            return refreshToken;
        }
    }


}