// Algoritmo Genético (configurado para maximização)
// Autor: Denis Ricardo da Silva Medeiros

clear;

// Parâmetros do AG
TAM_POP = 40;
NUM_GER = 30;
TAXA_CROSS = 0.8;
TAXA_MUT = 0.04;
L_MIN = -500;
L_MAX = 500;
QNT_BITS = 16;
ELITISMO = 0.02;
DIMENSOES = 2;

//rand('seed', 2330099)
//RESPOSTA = X perto de 440 e Y perto de -500.

// Função de avaliação.
function saida = fa(xn)
    x = xn(1);
    y = xn(2);
    z=-x.*sin(sqrt(abs(x)))-y.*sin(sqrt(abs(y)));
    x = x/250;
    y = y/250;
    r = 100*(y-x.^2).^2+(1-x).^2;
    r1 = (y-x.^2).^2+(1-x).^2;
    w = r .* z;
    w2 = z - r1;
    w6 = w + w2;
    saida = -w6;
endfunction

// ################################################################# //

// Calcula o ganho normalizado.
GANHO_NORM = (L_MAX - L_MIN)/(2^QNT_BITS - 1);

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
melhores  = zeros(NUM_GER, 1);
media  = zeros(NUM_GER, 1);

// Para o relatório
primeira = L_MIN + GANHO_NORM * pop_dec;;
intermediaria1 = primeira;
intermediaria2 = primeira;
ultima = primeira;

// Inicia o processamento das gerações.
for i = 1:NUM_GER
    
    // Normaliza os indivíduos.
    pop_norm = L_MIN + GANHO_NORM * pop_dec;
    
    if i == 3 then
        intermediaria1 = pop_norm;
    elseif i == 10 then
        intermediaria2 = pop_norm; 
    end
    
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


//        //Faz a seleção por torneio, com 2 indivíduos.
//        inds =  1 + floor(rand(2, 1)*TAM_POP);
//        if aptidao(inds(1)) > aptidao(inds(2)) then
//            k1 = inds(1);
//        else
//            k1 = inds(2);
//        end
//        
//        inds =  1 + floor(rand(2, 1)*TAM_POP);
//        if aptidao(inds(1)) > aptidao(inds(2)) then
//            k2 = inds(1);
//        else
//            k2 = inds(2);
//        end
        
        // Realiza o cruzamento dos dois indivíduos selecionados 
        // com base na taxa de cruzamento.
        filho1 = pop_bin(1, :);
        filho2 = pop_bin(1, :);
        for d=1:DIMENSOES     
            // Testa se passa da taxa de cruzamento.
            if rand(1) < TAXA_CROSS then
                // Define o ponto de corte.
                pos = 1 + floor((QNT_BITS-1)*rand(1));
                // Faz o cruzamento (quebra as strings e depois as une).
                partes1 = strsplit(pop_bin(k1, d), pos);
                partes2 = strsplit(pop_bin(k2, d), pos);
                filho1(1, d) = strcat([partes1(1), partes2(2)]);
                filho2(1, d) = strcat([partes2(1), partes1(2)]);
            else
                // Se não passou na taxa de cruzamento, passa os indivíduos
                // diretamente para a próxima população.
                filho1(1, d) = pop_bin(k1, d);
                filho2(1, d) = pop_bin(k2, d);
            end
        end
        
        // Adiciona os novos filhos na nova população. 
        nova_pop_bin(j,:) = filho1;
        nova_pop_bin(j+1,:) = filho2;
        
    end
    
    // Operação de mutação.
    for j=1:TAM_POP
        for d=1:DIMENSOES
            if rand(1) < TAXA_MUT then
                // Encontra o bit a ser mutado.
                pos = 1 + floor(QNT_BITS*rand(1));
                // Verifica se este bit é 1 ou 0 para alterar seu valor.
                bit = part(nova_pop_bin(j,d), pos);
                if bit == '1' then
                    nova_pop_bin(j, d) = strcat([part(nova_pop_bin(j, d), 1:pos-1), '0', part(nova_pop_bin(j, d), pos+1:QNT_BITS)])
                else
                    nova_pop_bin(j, d) = strcat([part(nova_pop_bin(j, d), 1:pos-1), '1', part(nova_pop_bin(j, d), pos+1:QNT_BITS)])
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
pop_norm = L_MIN + GANHO_NORM * pop_dec;
ultima = pop_norm;

for j=1:TAM_POP
    aptidao(j) = fa(pop_norm(j,:));
end
[_, indice] = max(aptidao);
resposta = pop_norm(indice, :);

//disp(pop_norm);
disp(['Resposta: ', string(resposta)]);


//erros = abs(fa(melhores_norm) - RESULTADO);

// Gráfico das aptidões.
function _ = plotar_aptidoes()
    clf();
    plot([1:NUM_GER]', melhores, '*-');
    plot([1:NUM_GER]', medias, 'go-');
    legend(['Melhor aptidão'; 'Média das aptidoẽs']);
    xlabel("Gerações");
    ylabel("Aptidão");
    title("Convergência da resposta");
    //grafico = gca() ;
    //grafico.box="on";  
    //grafico.data_bounds=[0, X_MIN; NUM_GER, X_MAX];  //define the bounds  
endfunction


// Gráficos das populações.
function _ = plotar_populacoes()
    scf();
    plot(primeira(:,1), primeira(:,2), 'ob');
    legend(['Indivíduos']);
    xlabel("X");
    ylabel("Y");
    title("População inicial");
    grafico = gca() ;
    grafico.box = "on";  
    grafico.data_bounds=[-500, -500; 500, 500]; 
    
    scf();
    plot(intermediaria1(:,1), intermediaria1(:,2), 'or');
    legend(['Indivíduos']);
    xlabel("X");
    ylabel("Y");
    title("População intermediária (após 3 gerações)");
    grafico = gca() ;
    grafico.box = "on";  
    grafico.data_bounds=[-500, -500; 500, 500];     
    
    scf();
    plot(intermediaria2(:,1), intermediaria2(:,2), 'om');
    legend(['Indivíduos']);
    xlabel("X");
    ylabel("Y");
    title("População intermediária (após 10 gerações)");
    grafico = gca() ;
    grafico.box = "on";  
    grafico.data_bounds=[-500, -500; 500, 500]; 
    
    scf();
    plot(ultima(:,1), ultima(:,2), 'og');
    legend(['Indivíduos']);
    xlabel("X");
    ylabel("Y");
    title("População final");   
    grafico = gca() ;
    grafico.box = "on";  
    grafico.data_bounds=[-500, -500; 500, 500]; 
    
endfunction

// Gráfico da função de avaliação.
function plotar_fa()
    [x, y] = meshgrid(-500:5:500,-500:5:500);
    z = -x.*sin(sqrt(abs(x)))-y.*sin(sqrt(abs(y)));
    x = x/250;
    y = y/250;
    // r: Rosenbrock's function
    r = 100*(y-x.^2).^2+(1-x).^2;
    r1 = (y-x.^2).^2+(1-x).^2;

    w = r .* z;
    w2 = z - r1;
    w6 = w + w2;
    x = x * 250;
    y = y * 250;
    surf(x, y, w6);
endfunction


