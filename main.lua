function love.load()
  function tratamento(msg)
    --Tratamento de conexão dos jogadores
    function tratamentoJogadores(nome)
      if listaJogadores[nome] == nil then
        listaJogadores[nome] = {tempo = 0, pos = 1}
        vetorJogadores[#vetorJogadores + 1] = nome
        numJogadores = numJogadores + 1
        --Timer para começar o jogo
        conectTimer = love.timer.getTime()
        if nome ~= user then
          mqtt.sendMessage("Conectado:"..user, canal)
          --Mandando numero do texto escolhido
          if textoEscolhido ~= nil then
            mqtt.sendMessage("Texto:"..textoEscolhido, canal)
          end
        end
      end
    end
    --Escolhendo o texto para jogar
    function tratamentoTexto()
      math.randomseed(os.time())
      num = math.random(1, #tabelaTextos)
      textoEscolhido = num
      textoReal = divideTexto()
      constantePos = (935/#textoReal)
    end
    function tratamentoAcerto(nome)
      if listaJogadores[nome]["pos"] == #textoReal then
        mqtt.sendMessage("ganhou:"..nome,canal)
      else
        listaJogadores[nome]["pos"] = listaJogadores[nome]["pos"] + 1
      end
    end
    function tratamentoVitoria(nome)
      --Trocando de fase
      local tempoFinal = gameTimer - tempoInicio
      vetorOrdenado[#vetorOrdenado + 1] = nome
      if nome == user then
        fase[3] = false
        fase[4] = true
        mqtt.sendMessage("tempo:"..user..":"..tempoFinal, canal)
      end
    end
    function tratamentoTempo(nome, resultado)
      listaJogadores[nome]["tempo"] = resultado
    end
    string.gsub(msg, "Conectado:(.+)", tratamentoJogadores)
    string.gsub(msg, "Escolhe", tratamentoTexto)
    string.gsub(msg, "acertou:(.+)", tratamentoAcerto)
    string.gsub(msg, "ganhou:(.+)", tratamentoVitoria)
    string.gsub(msg,"tempo:(.+):(.+)",tratamentoTempo)
  end
  --Divide o texto escolhido em palavras
  function divideTexto()
    function adiciona(palavra)
      --String da palavra, e valor que diz se ela já foi acertada
      textoDividido[#textoDividido + 1] = {palavra, 0}
    end
    
    textoDividido = {}
    padrao = "[ ]-(.-)[ ]"
    string.gsub(tabelaTextos[textoEscolhido][3], padrao, adiciona)
    textoDividido[1][1] = string.gsub(textoDividido[1][1], "(Texto:).-", "")
    
    return textoDividido
  end
  function preparaTextos(arquivo)
    --Preparar uma biblioteca de textos dado um arquivo
    function criaTabela(autor, livro, texto)
      tabelaTextos[#tabelaTextos + 1] = {livro, autor, texto}
    end
    --Importando textos
    arq = io.open(arquivo, "r")
    textos = arq:read("*a")
    arq:close()
    
    tabelaTextos = {}
    
    padrao = "%*(.-)%*(.-)%*(.-)%*"
    
    string.gsub(textos, padrao, criaTabela)
    
    return tabelaTextos
  end
  function start()
    love.graphics.draw(primeiro, 0,0)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Usuario : ", 200 , 200)
    love.graphics.print("Canal : ", 200 , 300)
    love.graphics.print("Você esta iniciando com o Usuario:  " .. login[1], 5, 400)
    love.graphics.print("Você esta entrando no canal: " .. login[2], 5, 500)
    --Desenhando Botäo de login
    love.graphics.setColor(0.2,0.2,0.2)
    love.graphics.rectangle("fill", 750, 50, 200, 100)
    if mouseX >= 750 and mouseX <= 950 and mouseY >= 50 and mouseY <= 150 then
      love.graphics.setColor(1,1,1)
    else
      love.graphics.setColor(0.3,0.3,0.3)
    end
    love.graphics.print("Entrar", 800, 79.5)
    --Desenhando palavras
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.print(login[2], 320,300)
    love.graphics.print(login[1], 350, 200)
  end
  function waiting()
    love.graphics.setColor(0.3,0.3,0.3)
    love.graphics.draw(fundo, 0,0)
    love.graphics.setBackgroundColor(0.8,0.2,0)
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(textFont)
    --Timer
    if conectTimer ~= nil and numJogadores >= 2 then
      love.graphics.print(string.format("Começa em: %ds", tostring(30 - (gameTimer-conectTimer))), 100)
    end
    --setup
    love.graphics.setColor(0,0,0)
    --Corrida:
    love.graphics.setLineWidth(2)
    love.graphics.setFont(nomeFont)
    for i = 1, numJogadores do
      jogador = vetorJogadores[i]
      love.graphics.line(25, 50 + (25 * i), 960, 50 + (25 * i ))
      love.graphics.setColor(1,1,1)
      --Escolhendo Posicao em relacao a quantidade de acertos
      if constantePos ~= nil and listaJogadores[jogador]["pos"] ~= nil then
        love.graphics.draw(pena, constantePos * listaJogadores[jogador]["pos"] ,32 + 25 * i, 0, 0.05, 0.05)
      end
      love.graphics.setColor(0,0,0)
      love.graphics.print(jogador, 20, 30 + 25 * i)
    end
    --Retangulos
    love.graphics.setFont(textFont)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", 20, 200, 960, 320)
    love.graphics.rectangle("line", 20, 540, 960, 50)
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", 23, 203, 954, 314)
    love.graphics.rectangle("fill", 23, 543, 954, 44)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Paralelepipedo", 27, 551)
    --Desenhar Texto no quadrado
    if textoEscolhido ~= nil then
      textoMostrado = ""
      textoAcertado = ""
      for i = 1, #textoReal do
        textoMostrado = textoMostrado .. " ".. textoReal[i][1]
        if textoReal[i][2] == 1 then
          textoAcertado = textoAcertado .. " " .. textoReal[i][1]
        end
      end
      love.graphics.printf(textoMostrado, 27, 210, 950)
      love.graphics.setColor(0,1,0)
      love.graphics.printf(textoAcertado, 27, 210, 950)
      love.graphics.printf(textoAcertado, 27, 210, 950)
      love.graphics.printf(textoAcertado, 27, 210, 950)
    end
    --
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(font)
    love.graphics.print(numJogadores.."/5")
    love.graphics.setColor(1,1,1)
    love.graphics.print("Esperando Jogadores", 320, 150)
    love.graphics.setColor(0.5,0.5,0.5)
    love.graphics.circle("fill", 370, 250, 25 * r1)
    love.graphics.circle("fill", 470, 250, 25 * r2)
    love.graphics.circle("fill", 570, 250, 25 * r3)
    
  end
  --
  function playing()
    if tempoInicio == nil then
      tempoInicio = love.timer.getTime()
    end
    --setup
    love.graphics.setColor(0.3,0.3,0.3)
    love.graphics.draw(fundo, 0,0)
    love.graphics.setColor(1,1,1)
    love.graphics.setColor(0,0,0)
    --Corrida:
    love.graphics.setLineWidth(2)
    love.graphics.setFont(nomeFont)
    for i = 1, numJogadores do
      jogador = vetorJogadores[i]
      love.graphics.line(constantePos, 50 + 25 * i , 960, 50 + 25 * i)
      love.graphics.setColor(1,1,1)
      --Escolhendo Posicao em relacao a quantidade de acertos
      if constantePos ~= nil and listaJogadores[jogador]["pos"] ~= nil then
        love.graphics.draw(pena, constantePos * listaJogadores[jogador]["pos"] ,32 + 25 * i, 0, 0.05, 0.05)
      end
      love.graphics.setColor(0,0,0)
      love.graphics.print(jogador, 20, 30 + 25 * i)
    end
    --Retangulos
    love.graphics.setFont(textFont)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", 20, 200, 960, 320)
    love.graphics.rectangle("line", 20, 540, 960, 50)
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", 23, 203, 954, 314)
    --Muda para vermelho se errar
    love.graphics.setColor(0.9,green,blue)
    love.graphics.rectangle("fill", 23, 543, 954, 44)
    love.graphics.setColor(0,0,0)
    --Texto Digitado
    --Se errar muda cor do texto para vermelho
    love.graphics.setColor(red,0,0)
    love.graphics.print(digitadoJogo, 27, 551)
    love.graphics.setColor(0,0,0)
    --
    if textoEscolhido ~= nil then
      textoMostrado = ""
      textoAcertado = ""
      for i = 1, #textoReal do
        textoMostrado = textoMostrado .. " ".. textoReal[i][1]
        if textoReal[i][2] == 1 then
          textoAcertado = textoAcertado .. " " .. textoReal[i][1]
        end
      end
      love.graphics.printf(textoMostrado, 27, 210, 950)
      love.graphics.setColor(0,1,0)
      love.graphics.printf(textoAcertado, 27, 210, 950)
      love.graphics.printf(textoAcertado, 27, 210, 950)
      love.graphics.printf(textoAcertado, 27, 210, 950)
    end
    
    love.graphics.setFont(font)
    --Contador
    love.graphics.setColor(1,1,1)
    love.graphics.print(numJogadores.."/5")
  end
  function result()
    love.graphics.setBackgroundColor (0.1 ,0.7 ,0.3)
    love.graphics.setColor(0.3,0.3,0.3)
    love.graphics.draw(final,0,0)
    love.graphics.setColor(1,1,1)
    --Printa nome de jogadores ordem
    for i = 1, #vetorOrdenado do
      if vetorOrdenado[i] ~= nil and i % 2 ~= 0 then
        tempoJogador = listaJogadores[vetorOrdenado[i]]["tempo"]
        love.graphics.print(string.format("O Jogador: ".. vetorOrdenado[i] .." acabou em %ds", tempoJogador) , 50, 30*i)
      end
    end
    love.graphics.print(tabelaTextos[textoEscolhido][2],30, 400)
    love.graphics.print(tabelaTextos[textoEscolhido][1], 30, 430)
  end
  love.window.setMode(1000, 600, {msaa=16})
  love.graphics.setBackgroundColor (0.3 ,0.3 ,0.7)
  font = love.graphics.newFont("DejaVuSerif.ttf", 30)
  textFont = love.graphics.newFont("DejaVuSerif.ttf", 23)
  nomeFont = love.graphics.newFont("DejaVuSerif.ttf", 15)
  love.keyboard.setKeyRepeat(true)
  love.graphics.setFont(font)
  utf8 = require("utf8")
  --Criando Tabela de textos
  preparaTextos("textos.txt")
  --
  --Start mqtt
  mqtt = require "mqttLoveLibrary"
  user = "abcd1"
  login = {}
  canal = "joginho321"
  --Setup
  fase = {true, false, false, false}
  login[1] = ""
  login[2] = ""
  escolhe = 1
  textoEscolhido = nil
  textoReal = nil
  conectar = 0
  love.window.setTitle ("Jogo de Digitação")
  --Variaveis necessarias
  final = love.graphics.newImage("final.png")
  pena = love.graphics.newImage("peninha.png")
  primeiro = love.graphics.newImage("start.jpg")
  fundo = love.graphics.newImage("fundo.jpeg")
  red = 0
  green = 0.9
  blue = 0.9
  digitadoJogo = ""
  r1 = 0
  r2 = 0 
  r3 = 0
  listaJogadores = {}
  vetorJogadores = {}
  vetorOrdenado = {}
  numJogadores = 0
  digitado = {}
  digitado2 = {}
  palavra = ""
  palavra2 = ""
  --
end
function love.draw()
  if fase[1] then
    start()
  elseif fase[2] then
    waiting()
  elseif fase[3] then
    playing()
  elseif fase[4] then
    result()
  end
end
function love.update(dt)
  gameTimer = love.timer.getTime()
  --Mouse
  mouseX, mouseY = love.mouse.getPosition()
  --Conectar mqtt
  if numJogadores == 1 and textoEscolhido == nil then
    mqtt.sendMessage("Escolhe", canal)
  end
  if conectar == 1 then
    mqtt.start("localhost", user, canal, tratamento)
    mqtt.sendMessage("Conectado:"..user, canal)
    conectar = 2
  end
  --Mudanca de fase
  if not fase[1] then
    love.window.setTitle ("User : " ..user.. " || Canal : " .. canal)
    mqtt.checkMessages()
  end
  if fase[2] then
    if r1 < 1 then
      r1 = r1 + 0.03
    elseif r1 >= 1 and r2 < 1 then 
      r2 = r2 + 0.03
    elseif r2 >= 1 and r3 < 1.2 then 
      r3 = r3 + 0.03
    end
    if r3 >= 1.2 then
      r1 = 0
      r2 = 0
      r3 = 0
    end
    if conectTimer ~= nil and numJogadores >= 2 then
      if gameTimer - conectTimer >= 30  then
        fase[2] = false
        fase[3] = true
      end
    end
  end
  if fase[3] then
    
  end
end
function love.mousepressed()
  if fase[1] then
    --Se o mouse estiver sobre o botäo e usuario e canal forem preenchidos
    if mouseX >= 750 and mouseX <= 950 and mouseY >= 50 and mouseY <= 150 and login[1]~= "" and login[2]~="" then
      user = login[1]
      canal = login[2]
      conectar = 1
      fase[1] = false
      fase[2] = true
    end
  end
end
function love.keypressed(key)
  if fase[1] then
    if key == "backspace" then
    -- get the byte offset to the last UTF-8 character in the string.
    byteoffset = utf8.offset(login[escolhe], -1)
    if byteoffset then
      login[escolhe] = string.sub(login[escolhe], 1, byteoffset - 1)
    end
    end
    if key == "up" then
      if escolhe == 2 then
        escolhe = 1
      end
    elseif key == "down" then
      if escolhe == 1 then
        escolhe = 2
      end
    elseif key == "return" then
      if escolhe == 1 then
        escolhe = 2
      elseif escolhe == 2 and user ~= "" and canal ~= "" and user ~= nil and canal ~= nil then
        user = login[1]
        canal = login[2]
        conectar = 1
        fase[1] = false
        fase[2] = true
      end
    end
  elseif fase[3] then
    if key == "backspace" then
      -- get the byte offset to the last UTF-8 character in the string.
      byteoffset = utf8.offset(digitadoJogo, -1)
      if byteoffset then
        digitadoJogo = string.sub(digitadoJogo, 1, byteoffset - 1)
      end
    end
    if key == "space" then
      print(digitadoJogo)
      print(textoReal[listaJogadores[user]["pos"]][1])
      if digitadoJogo == textoReal[listaJogadores[user]["pos"]][1] then
        red = 0 
        green = 0.9
        blue = 0.9
        textoReal[listaJogadores[user]["pos"]][2] = 1
        mqtt.sendMessage("acertou:"..user,canal)
        digitadoJogo = ""
      else
        red = 1
        green = 0.5
        blue = 0.5
      end
    end
  end
end
function love.textinput(text)
  if fase[1] then
    if escolhe == 1 then
      login[1] = login[1] .. text
    elseif escolhe == 2 then
      login[2] = login[2] .. text
    end
  elseif fase[3] then
    if digitadoJogo == " " then
      digitadoJogo = ""
    end
    digitadoJogo = digitadoJogo .. text
  end
end