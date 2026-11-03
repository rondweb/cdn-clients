Issue found: Invalid Privacy policy

Status: RESOLVIDO

A política de privacidade foi criada e publicada em `docs/privacy.html`. Ela está hospedada em `https://miranda-back.lnds.space/privacy` e agora retorna HTTP 200 (antes retornava 404).

Detalhes da resolução:

- O arquivo `docs/privacy.html` foi preenchido com uma política de privacidade completa em português (pt-BR), abrangendo:
  - Informações coletadas (cadastro, login Google, estilo, localização, fotos, identificador de usuário, token de sessão, etapa de onboarding, plano de assinatura, ID do parceiro, dados de uso, informações do dispositivo)
  - Serviços de terceiros utilizados (Appwrite, RevenueCat, PostHog, Google Play Store)
  - Como as informações são usadas
  - Compartilhamento de informações
  - Armazenamento e segurança dos dados
  - Direitos do usuário (acesso, correção, exclusão, portabilidade)
  - Privacidade de crianças
  - Transferências internacionais de dados
  - Cookies e tecnologias similares
  - Links para outros sites e serviços
  - Alterações na política
  - Contato

- Também foi criado o arquivo `docs/terms.html` com os Termos de Serviço, exigido pela Play Store para apps com contas de usuário e assinaturas pagas.

Próximos passos para enviar para revisão no Google Play Console:

1. Garanta que o arquivo `privacy.html` esteja publicado em `https://miranda-back.lnds.space/privacy` e retorne HTTP 200.
2. Acesse o Play Console > Política de conteúdo > Privacidade.
3. Informe a URL da política de privacidade: `https://miranda-back.lnds.space/privacy`.
4. Salve as alterações.
5. Vá para Visão geral da publicação e envie as alterações para revisão.

Se a política de privacidade ou o site onde ela está hospedada precisarem de atualizações, faça essas mudanças fora do Play Console antes de enviar as mudanças para o Google para revisão.

Sobre a seção Política de Privacidade da política de Dados do Usuário:

Todos os apps devem postar um link de política de privacidade no campo designado no Play Console, e um link ou texto de política de privacidade dentro do próprio app. A política de privacidade deve, juntamente com quaisquer divulgações no app, divulgar abrangentemente como seu app acessa, coleta, usa e compartilha dados do usuário, não limitado pelos dados divulgados na seção Data safety.
