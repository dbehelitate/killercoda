# Step 4: Hello World.


```bash
POD_IP=$(kubectl get pod tiny-gguf -n kserve-test -o jsonpath='{.status.podIP}')

curl -s -X POST http://$POD_IP:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a highly creative sci-fi AI. Generate a numbered list of 3 dramatic, cinematic ways to say '\''Hello World'\''. You MUST use cool and relevant emojis (like 🤖, 🌌, 🚀, ⚡) in every single line."},
      {"role": "user", "content": "Give me 3 sci-fi variations of Hello World with emojis!"}
    ],
    "max_tokens": 150,
    "temperature": 0.8
  }' | jq -r '.choices[0].message.content'
```{{exec}}

Is everything ok? 
Click and Play! 🎈 Now let's open a magic window to chat with our robot!

```bash
kubectl port-forward --address 0.0.0.0 pod/tiny-gguf -n kserve-test 8080:8080 > /dev/null 2>&1 &
```{{exec}}

Now click the Traffic or Ports button at the top of your Killercoda screen, type 8080, and click the link to open your robot chat window!
