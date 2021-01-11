function preparaTextos()
    function criaTabela(autor, livro, texto)
      tabelaTextos[#tabelaTextos + 1] = {livro, autor, texto}
    end
    --Importando textos
    arq = io.open("textos.txt", "r")
    textos = arq:read("*a")
    arq:close()
    
    tabelaTextos = {}
    
    padrao = "%*(.-)%*(.-)%*(.-)%*"
    
    string.gsub(textos, padrao, criaTabela)
    
    return tabelaTextos
end
opa = preparaTextos()
textoEscolhido = 7
function divideTexto()
  function adiciona(palavra)
    textoDividido[#textoDividido + 1] = palavra
  end
  textoDividido = {}
  padrao = "[ ]-(.-)[ ]"
  string.gsub(tabelaTextos[textoEscolhido][3], padrao, adiciona)
  textoDividido[1] = string.gsub(textoDividido[1], "(Texto:).-", "")
  return textoDividido
end
opa = divideTexto()
print(opa[1])
---
function love.keypressed(key)
  if fase[1] then
    if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
      key = string.upper(key)
    end
    if escolhe == 1 then
      if key == "backspace" then
        digitado[#digitado] = nil
      elseif key == "RSHIFT" or key == "LSHIFT" then
        --Do nothing
      elseif key == "return" then
        if escolhe == 1 then
          login[1] = palavra
          escolhe = 2
        elseif escolhe == 2 then
          login[2] = palavra
          escolhe = 1
        end
      elseif key == "up" then
        if escolhe == 2 then
          escolhe = 1
        end
      elseif key == "down" then
        if escolhe == 1 then
          escolhe = 2
        end
      elseif key == "space" then
        digitado[#digitado + 1] = " "
      else
        digitado[#digitado + 1] = key
      end
    elseif escolhe == 2 then
      if key == "backspace" then
        digitado2[#digitado2] = nil
      elseif key == "RSHIFT" or key == "LSHIFT" then
        --Do nothing
      elseif key == "return" then
        if escolhe == 1 then
          login[1] = palavra
          escolhe = 2
        elseif escolhe == 2 then
          login[2] = palavra
          escolhe = 1
        end
      elseif key == "up" then
        if escolhe == 2 then
          escolhe = 1
        end
      elseif key == "down" then
        if escolhe == 1 then
          escolhe = 2
        end
      elseif key == "space" then
        digitado2[#digitado2 + 1] = " "
      else
        digitado2[#digitado2 + 1] = key
      end
    end
      palavra = ""
      if escolhe == 1 then
        for i = 1, #digitado do
          palavra = palavra .. digitado[i]
        end
      elseif escolhe == 2 then
        for i = 1, #digitado2 do
          palavra = palavra .. digitado2[i]
        end
      end
  end
end
