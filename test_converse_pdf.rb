require 'aws-sdk-bedrockruntime'
require 'base64'
require 'json'

# Initialize the Bedrock client
bedrock = Aws::BedrockRuntime::Client.new(
  region: 'us-east-1'
)

# Read the PDF file
pdf_path = 'sample.pdf'
pdf_content = File.binread(pdf_path)

# Initialize conversation history
messages = [
  {
    role: "user",
    content: [
      {
        text: "I'm going to show you a PDF document. Please analyze its contents with 10 bullet points."
      },
      {
        document: {
          name: "sample",
          format: "pdf",
          source: {
            bytes: pdf_content
          }
        }
      }
    ]
  }
]

# Function to send a message and get a response
def send_message(bedrock, messages)
  response = bedrock.converse(
    model_id: "anthropic.claude-3-sonnet-20240229-v1:0", # Claude 3 Sonnet model ID
    messages: messages,
    inference_config: {
        max_tokens: 1000,
        temperature: 0.7,
        top_p: 1.0
    }
  )

  # Extract and return relevant information from the response
  {
    text: response.output.message.content.first.text,
    role: response.output.message.role,
    stop_reason: response.stop_reason,
    input_tokens: response.usage.input_tokens,
    output_tokens: response.usage.output_tokens,
    total_tokens: response.usage.total_tokens,
    latency_ms: response.metrics.latency_ms
  }
end

# Function to display the response
def display_response(response)
  puts "Assistant: #{response[:text]}"
  puts "Role: #{response[:role]}"
  puts "Stop Reason: #{response[:stop_reason]}"
  puts "Tokens: Input #{response[:input_tokens]}, Output #{response[:output_tokens]}, Total #{response[:total_tokens]}"
  puts "Latency: #{response[:latency_ms]} ms"
  puts "---"
end

# Main conversation loop
puts "Starting conversation. Type 'exit' to end."
loop do
  # Get assistant's response
  response = send_message(bedrock, messages)
  display_response(response)

  # Get user input
  print "You: "
  user_input = gets.chomp

  break if user_input.downcase == 'exit'

  # Add user input to messages
  messages << {
    role: "user",
    content: [{ text: user_input }]
  }
end

puts "Conversation ended."
