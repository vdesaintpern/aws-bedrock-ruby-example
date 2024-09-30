require 'aws-sdk-bedrockruntime'
require 'base64'
require 'json'

# Initialize the Bedrock client
bedrock = Aws::BedrockRuntime::Client.new(region: 'us-east-1')

# Load the image
image_path = 'image_to_analyse.png'
image_data = File.read(image_path)

# Prepare the initial message with the image
initial_message = {
  role: 'user',
  content: [
    {
      image: {
        format: 'png',
        source: { bytes: image_data }
      }
    },
    {
      text: 'Please analyze this image and describe what you see.'
    }
  ]
}

# Start the conversation
messages = [initial_message]

loop do
  # Send the request to Claude 3.5
  response = bedrock.converse({
    model_id: 'anthropic.claude-3-sonnet-20240229-v1:0',
    messages: messages,
    inference_config: {
      max_tokens: 1000,
      temperature: 0.7,
      top_p: 1.0
    }
  })

  # Print the response
  assistant_message = response.output.message
  if assistant_message.role == 'assistant'
    assistant_message.content.each do |content|
      if content.text
        puts content.text
      elsif content.image
        puts "Image received: #{content.image.format}"
      elsif content.document
        puts "Document received: #{content.document.name} (#{content.document.format})"
      end
    end
  end

  # Print usage information
  puts "\nUsage:"
  puts "Input tokens: #{response.usage.input_tokens}"
  puts "Output tokens: #{response.usage.output_tokens}"
  puts "Total tokens: #{response.usage.total_tokens}"

  # Ask if the user wants to continue
  print "\nDo you want to continue the conversation? (y/n): "
  user_input = gets.chomp.downcase
  break if user_input != 'y'

  # If continuing, add the assistant's response to the conversation
  messages << assistant_message

  # Ask for user input
  print "Enter your next question or prompt: "
  user_question = gets.chomp

  # Add the user's new message to the conversation
  messages << {
    role: 'user',
    content: [{ text: user_question }]
  }
end

puts "Conversation ended."
