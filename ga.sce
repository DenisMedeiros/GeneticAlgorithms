// Algoritmo Genético (configurado para maximização)
// Autor: Denis Ricardo da Silva Medeiros

// Parâmetros do AG
TAM_POP = 30;
NUM_GER = 40;
TAXA_CROSS = 0.8;
TAXA_MUT = 0.001;
X_MIN = -10;
X_MAX = 10;
QNT_BITS = 10;
ELITISMO = 0.05;
DIMENSOES = 2;

// Função de Avaliação
//function y = fa(xn)
//    y = -(xn.^2 - 3*xn +4);
//endfunction

function y = fa(xn)
    y = -(xn(1).^2 + xn(2).^2);
endfunction

// ################################################################# //

// Calcula o ganho normalizado.
GANHO_NORM = (X_MAX - X_MIN)/(2^QNT_BITS - 1);

// Cria a população inicial com strings.
pop_bin = [];
for d=1:DIMENSOES
    pop_bin_t = [];
    for i = 1:TAM_POP
        pop_bin_t = [pop_bin_t; strcat(string(round(rand(1, QNT_BITS))))];
    end
    pop_bin = [pop_bin pop_bin_t];
end

pop_dec = bin2dec(pop_bin);
nova_pop_bin = pop_bin;
aptidao = zeros(TAM_POP, 1);
melhores  = zeros(NUM_GER,1);
media  = zeros(NUM_GER,1);

// Inicia o processamento das gerações.
for i = 1:NUM_GER
    
    // Normaliza os indivíduos.
    pop_norm = X_MIN + GANHO_NORM * pop_dec;
    
    // Avalia os indivíduos.
    for j=1:TAM_POP
        aptidao(j) = fa(pop_norm(j,:));
    end
    
    // Garante que todas as aptidões sejam positivas.
    aptidao = aptidao - min(aptidao);
    aptidao = aptidao + 0.01*max(aptidao);
    aptidao_acc = cumsum(aptidao);
    
    // Armazena o melhor da geração atual.
    [aptidao_ord, indices_ord] = gsort(aptidao);
    melhores(i) = aptidao_ord(1);
    medias(i) = mean(aptidao);
    
    // Faz a seleção dos indivíduos através do método da roleta.
    for j = 1:2:TAM_POP
        
        // Faz o primeiro giro da roleta.
        valor = aptidao_acc(TAM_POP) * rand(1);
        for k1 = 1:TAM_POP
            if valor < aptidao_acc(k1) then
                break;
            end
        end    
        
        // Faz o segundo giro da roleta.
        valor = aptidao_acc(TAM_POP) * rand(1);
        for k2 = 1:TAM_POP
            if valor < aptidao_acc(k2) then
                break;
            end
        end    
        
        // Realiza o cruzamento dos dois indivíduos selecionados 
        // com base na taxa de cruzamento.
        filho1 = zeros(1,2);
        filho2 = zeros(1,2);
        for d=1:DIMENSOES     
            if rand(1) < TAXA_CROSS then
                pos = 1 + floor((QNT_BITS-1)*rand(1));
                partes1 = strsplit(pop_bin(k1,d), pos);
                partes2 = strsplit(pop_bin(k2,d), pos);
                filho1 = strcat([partes1(1), partes2(2)]);
                filho2 = strcat([partes2(1), partes1(2)]);
            else
                filho1 = pop_bin(k1,:);
                filho2 = pop_bin(k2,:);
            end
            
                    // Adiciona os novos filhos na nova população. 
        nova_pop_bin(j,:) = filho1;
        nova_pop_bin(j+1,:) = filho2;
        end
    end
    
    // Aplica a mutação em alguns indivíduos (nos primeiros).
    for j=1:TAM_POP
       for d=1:DIMENSOES
          if rand(1) < TAXA_MUT then
               pos = 1 + floor(QNT_BITS*rand(1));
               bit = part(nova_pop_bin(j,d), pos);
               if bit == '1' then
                   nova_pop_bin(j,d) = strcat([part(nova_pop_bin(j,d), 1:pos-1), '0', part(nova_pop_bin(j,d), pos+1:QNT_BITS)])
               else
                   nova_pop_bin(j,d) = strcat([part(nova_pop_bin(j,d), 1:pos-1), '1', part(nova_pop_bin(j,d), pos+1:QNT_BITS)])
               end
           end
       end
    end
    
    // Aplica o elitismo.
    inds_elite = round(ELITISMO*TAM_POP);
    nova_pop_bin(1:inds_elite) = pop_bin(indices_ord(1:inds_elite));
    
    // Substitui a população antiga.
    pop_bin = nova_pop_bin
    
    // Gera a população de decimais.
    pop_dec = bin2dec(pop_bin)

end

// Obtém o melhor indivíduo.
pop_norm = X_MIN + GANHO_NORM * pop_dec;
//melhores_norm = X_MIN + GANHO_NORM * melhores;
aptidao = fa(pop_norm);
[_, indice] = max(aptidao);
pop_norm = X_MIN + GANHO_NORM * pop_dec;
disp(pop_norm);
disp(['Resposta: ', string(pop_norm(indice, :))]);

//erros = abs(fa(melhores_norm) - RESULTADO);
clf();
plot([1:NUM_GER]', melhores, '*-');
plot([1:NUM_GER]', medias, 'go-');
legend(['Melhor aptidão'; 'Média das aptidoẽs']);
xlabel("Gerações");
ylabel("Indivíduos");
title("Convergência da resposta");
//grafico = gca() ;
//grafico.box="on";  
//grafico.data_bounds=[0, X_MIN; NUM_GER, X_MAX];  //define the bounds  
