# 💡 Chatbot Frontend (Flutter)

O frontend é desenvolvido em **Flutter**.  
O projeto está encapsulado em um **Widget**, permitindo fácil exportação para um projeto de maior porte.

---

## ▶️ Como rodar

1. Instale o **Flutter SDK**
2. Execute o comando:

   ```bash
   flutter run
   ```

3. Rode o projeto no ambiente desejado  
   ✅ Recomendado: Executar no navegador (`Chrome`, `Edge`, etc.)

Esse frontend se comunica com o backend via requisições HTTP e exibe o resultado na tela de forma simples e eficiente.



---



# 🧠 Chatbot Backend (DialoGPT + Flask)

Este é um backend simples em Python que utiliza o modelo [`DialoGPT-medium`](https://huggingface.co/microsoft/DialoGPT-medium) para gerar respostas de um chatbot. Ele expõe uma API via Flask que pode ser consumida por qualquer frontend, como um app Flutter.

## ▶️ Como Rodar

### 1. Instale as dependências

```bash
pip install flask transformers torch
```

### 2. Execute o servidor

```bash
python app.py
```

---

## 📡 Endpoints da API

### `POST /chat`

**Descrição:** Envia uma mensagem para o chatbot e recebe uma resposta gerada.

- **URL:** `http://localhost:5000/chat`  
- **Método:** `POST`  
- **Headers:**  
  `Content-Type: application/json`  
- **Body (exemplo):**

```json
{
  "message": "Olá, tudo bem?"
}
```

- **Resposta:**

```json
{
  "reply": "Olá, tudo bem? Como posso te ajudar hoje?"
}
```
