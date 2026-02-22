# linuxmint-custom-iso-pt-br
Templates e scripts para gerar uma ISO customizada do Linux Mint com o [Cubic (Custom Ubuntu ISO Creator)](https://github.com/PJ-Singh-001/Cubic).

Passo 1: Baixe a ISO do Linux Mint em https://linuxmint.com/download.php;

Passo 2: Clone este repositório com `git clone https://github.com/thiagoneo/linuxmint-custom-iso-pt-br.git`;

Passo 3: Abra o Cubic, selecione como pasta do projeto a pasta do repositório (linuxmint-custom-iso-pt-br), e selecione o arquivo ISO baixado;

Passo 4: Após o Cubic carregar a ISO, será aberto uma janela de terminal azul; execute o script que fará as modificações na ISO com o comando `https://github.com/thiagoneo/linuxmint-custom-iso-pt-br/blob/main/run_inside_chroot.sh | bash`; após o script concluir, NÃO clique em "Next" ainda;

Passo 5: Abra um segundo terminal dentro da pasta `linuxmint-custom-iso-pt-br`; execute o script que criará os arquivos para automatizar a instalação `./generate_preseed_file.sh`. Digite um nome de usuário e senha para o administrador do sistema.

Passo 6: Retorne à janela do Cubic, clique no botão "Next" até finalizar. Recomendamos selecionar o algoritmo `zstd`, que é rápido e eficiente para compactação da imagem.
