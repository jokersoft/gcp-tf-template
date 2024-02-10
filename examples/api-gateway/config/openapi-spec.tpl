swagger: '2.0'
info:
  title: Example API
  description: This is a simple example of an OpenAPI specification.
  version: '1.0.0'
host: '${api_gateway_id}-${region}.apigateway.${project}.cloud.goog'
schemes:
  - https
paths:
  /api/v1/app:
    get:
      summary: Example endpoint
      description: test description
      operationId: getAppData # Unique operation ID
      x-google-backend:
        address: ${service_address}
      responses:
        200:
          description: A successful response
          schema:
            type: object
            properties:
              message:
                type: string
