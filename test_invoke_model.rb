require 'aws-sdk-bedrockruntime'
require 'base64'
require 'json'

# Initialize the Bedrock client
bedrock = Aws::BedrockRuntime::Client.new(region: 'us-east-1')

# Load and encode the image
image_path = 'image_to_analyse.png'
encoded_image = Base64.strict_encode64(File.read(image_path))

# Prepare the request payload
payload = {
  anthropic_version: 'bedrock-2023-05-31',
  max_tokens: 1000,
  messages: [
    {
      role: 'user',
      content: [
        { type: 'image', source: { type: 'base64', media_type: 'image/png', data: encoded_image } },
        { type: 'text', text: 'Please analyze this image and describe what you see.' }
      ]
    }
  ]
}

# Send the request to Claude 3.5
response = bedrock.invoke_model({
  body: JSON.generate(payload),
  model_id: 'anthropic.claude-3-sonnet-20240229-v1:0',
  content_type: 'application/json',
  accept: 'application/json'
})

# Parse and print the response
result = JSON.parse(response.body.read)
puts result['content'][0]['text']