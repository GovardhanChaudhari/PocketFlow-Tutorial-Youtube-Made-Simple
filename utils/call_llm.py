import os
import ollama # Add Ollama import

def call_llm(prompt: str) -> str:
    # Use Ollama client
    try:
        # Get Ollama host from environment variable, default if not set
        ollama_host = os.getenv("OLLAMA_HOST", "http://localhost:11435")
        client = ollama.Client(host=ollama_host)

        # Get context window size from environment variable, default to 32768
        default_num_ctx = 2048 # Keep 2k as default, but configurable
        num_ctx_str = os.getenv("OLLAMA_NUM_CTX", str(default_num_ctx))
        try:
            num_ctx = int(num_ctx_str)
            if num_ctx <= 0:
                print(f"Warning: Invalid OLLAMA_NUM_CTX value '{num_ctx_str}'. Using default {default_num_ctx}.")
                num_ctx = default_num_ctx
        except ValueError:
            print(f"Warning: OLLAMA_NUM_CTX is not a valid integer ('{num_ctx_str}'). Using default {default_num_ctx}.")
            num_ctx = default_num_ctx

        # Get Ollama model name from environment variable, default if not set
        default_model = 'qwen3:30b-a3b'
        ollama_model = os.getenv("OLLAMA_MODEL", default_model)
        if not ollama_model:
            print(f"Warning: OLLAMA_MODEL environment variable is empty. Using default '{default_model}'.")
            ollama_model = default_model

        response = client.chat(
            model=ollama_model, # Use the model from env var or default
            messages=[{'role': 'user', 'content': prompt}],
            options={
                'num_ctx': num_ctx  # Use context window size from env var or default
            }
        )
        # Extract the content from the response
        return response['message']['content']
    except Exception as e:
        print(f"Error calling Ollama: {e}")
        # Handle connection errors or other issues
        return f"Error communicating with Ollama: {e}"

if __name__ == "__main__":
    # Example usage when running the script directly
    # Get Ollama host from environment variable for testing
    ollama_host_test = os.getenv("OLLAMA_HOST", "http://localhost:11435")
    print(f"Attempting to connect to Ollama at {ollama_host_test}...")

    # Optional: Add a simple connection check here if desired
    try:
        client = ollama.Client(host=ollama_host_test)
        client.list() # Simple command to check connection
        print("Ollama connection check successful.")
    except Exception as e:
        print(f"Failed to connect to Ollama: {e}")
        print(f"Please ensure the Ollama server is running and accessible at {ollama_host_test}.")
        # Decide if you want to exit here or still try the call_llm
        # exit(1) # Uncomment to exit if connection fails

    test_prompt = "Explain the concept of a Large Language Model in one sentence."
    print(f"Sending test prompt to Ollama: '{test_prompt}'")
    response = call_llm(test_prompt)
    print(f"Response: {response}")
