from flask import Flask, request, jsonify
from transformers import pipeline
from flask_cors import CORS
import random

app = Flask(__name__)
CORS(app) 

try:
    modelo_ia = pipeline("text-generation", model="microsoft/DialoGPT-medium")
except:
    print("Aviso: Não foi possível carregar o modelo DialoGPT. O chatbot funcionará apenas com respostas pré-definidas.")
    modelo_ia = None

base_conhecimento = {
    "boas_vindas": [
        "Olá! Eu sou o assistente virtual da Alugaai. Estou aqui para te ajudar a encontrar a moradia ideal. Como posso ajudar?",
        "Bem-vindo ao Alugaai! Sou seu assistente virtual. Está procurando um lugar para morar ou deseja cadastrar uma propriedade?",
        "Oi! Sou o bot do Alugaai. Vamos encontrar a acomodação perfeita pra você?"
    ],
    
    "cadastro": [
        "Para se cadastrar, clique no botão 'Criar conta' na tela inicial. Você precisará informar seus dados pessoais, incluindo CPF para verificação, e selecionar a universidade de interesse.",
    ],

    "busca_estudantes": [
        "No feed principal, você verá perfis de estudantes interessados na mesma universidade. Deslize para direita para demonstrar interesse ou para esquerda para passar.",
    ],

    "mapa": [
        "O mapa exibe universidades e propriedades disponíveis. Clique em uma universidade para ver estudantes interessados nela ou em uma propriedade para ver detalhes.",
    ],

    "filtros_feed": [
        "Acesse as configurações de filtro no feed, selecione 'Curso' e escolha a opção desejada. Você também pode filtrar por idade, interesses e preferências de moradia.",
    ],

    "conexoes": [
        "Quando duas pessoas se conectam, abrimos um chat privado para vocês conversarem sobre possibilidades de moradia compartilhada.",
    ],

    "seguranca": [
        "Todos os usuários passam por verificação de CPF. Também temos um sistema de avaliações e recomendamos encontros iniciais em locais públicos.",
    ],

    "proprietarios": [
        "Quando um estudante se interessa pelo seu imóvel, você recebe uma notificação e pode iniciar uma conversa pelo chat da plataforma.",
    ],
    
    "travamento": [
        "Primeiro, tente fechar e abrir novamente o aplicativo. Se o problema persistir, vá em 'Configurações > Suporte > Relatar problema' para enviar um relatório detalhado.",
    ],

    "problemas": [
        "Se estiver enfrentando problemas com o app, tente reiniciar. Caso continue, entre em contato pelo e-mail suporte@alugaai.com.",
        "Você pode relatar qualquer erro ou bug diretamente pelo menu 'Ajuda' no app.",
        "Problemas técnicos? Estamos aqui para ajudar! Acesse o suporte no aplicativo ou envie um e-mail para nossa equipe."
    ],

    "generico": [
        "Desculpe, não entendi sua pergunta. Pode reformular ou acessar o menu de ajuda no app?",
        "Ainda estou aprendendo! Tente perguntar de outra forma ou fale com nosso suporte pelo app.",
        "Essa informação talvez não esteja disponível no momento. Você pode tentar outra dúvida ou consultar o FAQ."
    ],
    
    "adeus": [
        "Tchau! Qualquer dúvida, estarei aqui para ajudar!",
    ],
}

palavras_chave = {
    "boas_vindas": ["olá", "oi", "ola", "bom dia", "boa tarde", "boa noite", "começar", "início"],
    "cadastro": ["cadastro", "cadastrar", "criar conta", "registro", "perfil"],
    "busca_estudantes": ["compatíveis", "colegas", "moradia", "compartilhada", "perfil", "estudantes"],
    "mapa": ["mapa", "localização", "proximidade", "visualizar imóveis", "ver imóveis", "ver no mapa"],
    "filtros_feed": ["filtros", "feed", "buscar imóveis", "preferências", "refinar busca", "apenas", "meu curso"],
    "conexoes": ["conexões", "interação", "solicitação", "mensagem", "contato", "chat"],
    "seguranca": ["segurança", "verificação", "seguro", "confiança", "perfil verificado", "confiaveis", "confiável"],
    "proprietarios": ["proprietário", "anunciar", "cadastrar imóvel", "colocar imóvel", "taxa", "divulgação", "interessados", "imóvel", "alugar"],
    "problemas": ["erro", "problema", "bug", "falha", "suporte", "ajuda"],
    "travamento": ["travando", "travamento", "lagando", "lento"],
    "generico": ["não sei", "não entendi", "outra dúvida", "outra questão"],
    "adeus": ["tchau", "flw", "adeus", "até logo"]
}

def identificar_intencao(pergunta):
    pergunta = pergunta.lower()

    for categoria, termos in palavras_chave.items():
        for termo in termos:
            if termo in pergunta:
                return categoria

    return "generico"

def responder_pergunta(pergunta):
    intencao = identificar_intencao(pergunta)

    if intencao and intencao in base_conhecimento:
        return random.choice(base_conhecimento[intencao])

    if modelo_ia:
        try:
            resposta_modelo = modelo_ia(pergunta, max_length=50, num_return_sequences=1)
            return resposta_modelo[0]['generated_text']
        except:
            pass

    return "Desculpe, não consegui entender sua pergunta. Poderia reformulá-la ou entrar em contato com nossa secretaria pelo telefone (11) 1234-5678?"

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    user_input = data.get("message", "")

    resposta = responder_pergunta(user_input)
    if resposta:
        return jsonify({"reply": resposta})
    elif modelo_ia:
        resposta = modelo_ia(user_input, max_length=50, pad_token_id=50256)[0]['generated_text']
        return jsonify({"reply": resposta})
    else:
        return jsonify({"reply": "Desculpe, não entendi. Pode reformular?"})

if __name__ == '__main__':
    app.run(debug=True, port=5000)