## Setup

After install of the Apex Classes, Remote Sites and Custom Metadata Types you will need to create.

1. An Auth. Provider of type HEAT_ClientCredentialAuthProvider. Populate the Client Id, Client Secret, Token URL and Scope as per the HEAT documentation under Client Credentials (https://data.api.heat.ac.uk/identity/docs)
2. After saving, copy the value of the Callback URL generated in the Salesforce Config section to the Callback URL parameter of the Auth. Provider
![image](https://user-images.githubusercontent.com/41118121/181124189-5b19ace1-eb73-4188-8120-875c07e01559.png)
3. Create a Named Credential record with the Authentication Type of Named Principal, OAuth 2.0 and the Auth. Provider you just created
![image](https://user-images.githubusercontent.com/41118121/181124319-20bb2a1a-45b7-4a38-a36d-cd3ce983e9a0.png)
4. If all is set up correctly, when you save this record, it should acquire the first access token in the background and then redirect you to the same page but the Authentication Status should read Authenticated as Client Credentials (If you see an error, check the Apex Logs of the Running User set on the Auth. Provider)

The Named Credential should be setup and any calls using it will automatically use the active token or get a new one before each call.


## External Services
As this is now set up correctly, you can configure an [External Service](https://help.salesforce.com/s/articleView?id=sf.external_services.htm&language=en_US&r=https%3A%2F%2Fwww.google.com%2F&type=5) to make the functions of the API available for use in Flows or other no-code solutions

When creating a new External Service, provide the Swagger/OpenAPI path HEAT provides under /docs/2/swagger
![image](https://user-images.githubusercontent.com/41118121/181124882-8837f842-b0e5-49f9-a1a2-f3cfef72955f.png)
You can then select any and all methods you want to make available to Flows and Processes. 
![image](https://user-images.githubusercontent.com/41118121/181125044-45b4f38b-4484-43ec-8925-3b175ad26fff.png)


N.B. You may still have to refer to the [HEAT API Docs](https://data.api.heat.ac.uk/index) as there are some items in the OpenAPI definiton which are functionally required such as api-version but not set as such in the spec)
