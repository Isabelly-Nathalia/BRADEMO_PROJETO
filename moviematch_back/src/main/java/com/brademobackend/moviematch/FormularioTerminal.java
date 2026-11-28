
package com.brademobackend.moviematch;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.model.RecomendacaoPedido;
import com.brademobackend.moviematch.model.RecomendacaoResposta;
import com.brademobackend.moviematch.model.Usuario;
import com.brademobackend.moviematch.service.AutenticacaoService;
import com.brademobackend.moviematch.service.ListaService;
import com.brademobackend.moviematch.service.RecomendacaoService;
import com.brademobackend.moviematch.service.UsuarioService;
import com.brademobackend.moviematch.model.Lista;

@Service
public class FormularioTerminal {

    @Autowired
    private AutenticacaoService autenticacaoService;

    @Autowired
    private RecomendacaoService recomendacaoService;

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private ListaService listaService;

    private final BlockingQueue<String> entradas = new LinkedBlockingQueue<>();

    private volatile boolean leitorIniciado = false;

    private long ultimaVersaoLogin = 0;

    private static class ReiniciarFormularioException
            extends RuntimeException {
    }

    private static class EncerrarAplicacaoException
            extends RuntimeException {
    }

    
public boolean executar() {

    iniciarLeitor();

    System.out.println("\n===== MOVIEMATCH =====");
    System.out.println("Bem-vindo ao MovieMatch!");

    try {

        System.out.println("\n===== FORMULÁRIO DE RECOMENDAÇÃO =====");

        executarFormulario(false);

        while (true) {
            verificarNovoLogin();
            Thread.sleep(300);
        }

    } catch (EncerrarAplicacaoException e) {

        System.out.println("\nMovieMatch finalizado.");
        return false;

    } catch (ReiniciarFormularioException e) {

        Usuario usuario =
                autenticacaoService.getUsuarioAutenticado();

        if (usuario == null) {
            return false;
        }

        System.out.println("\n===== USUÁRIO AUTENTICADO =====");
        System.out.println("Bem-vindo, " + usuario.getNome_usuario() + "!");

        System.out.println("\n===== NOVO FORMULÁRIO =====");

        try {
            executarFormulario(true);
        } catch (EncerrarAplicacaoException ex) {
            System.out.println("\nMovieMatch finalizado.");
            return false;
        }

        System.out.println("\nFormulário finalizado.");
        System.out.println("\nMovieMatch finalizado.");

        return false;

    } catch (InterruptedException e) {

        Thread.currentThread().interrupt();
        return false;
    }
}


    private void iniciarLeitor() {

        if (leitorIniciado) {
            return;
        }

        leitorIniciado = true;

        Thread leitor = new Thread(() -> {

            try (Scanner scanner = new Scanner(System.in)) {

                while (scanner.hasNextLine()) {
                    entradas.put(scanner.nextLine());
                }

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }

        });

        leitor.setDaemon(true);
        leitor.start();
    }

    private String lerEntrada() {
        while (true) {
            verificarNovoLogin();
            try {
                String entrada = entradas.poll(300, TimeUnit.MILLISECONDS);
                if (entrada != null) {
                    return entrada;
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new EncerrarAplicacaoException();
            }
        }
    }

    private String lerEntradaSemVerificarLogin() {
        try {
            return entradas.take();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new EncerrarAplicacaoException();
        }
    }

    private void verificarNovoLogin() {

        long versaoAtual = autenticacaoService.getVersaoLogin();

        if (versaoAtual > ultimaVersaoLogin) {

            ultimaVersaoLogin = versaoAtual;

            Usuario usuario = autenticacaoService.getUsuarioAutenticado();

            if (usuario == null) {
                return;
            }

            System.out.println("\n\n===== LOGIN REALIZADO COM SUCESSO =====");
            System.out.println("Bem-vindo, " + usuario.getNome_usuario() + "!");

            System.out.println("\nDeseja responder ao formulário novamente?");
            System.out.println("1 - Sim");
            System.out.println("2 - Não");
            System.out.print("Escolha uma opção: ");

            while (true) {

                String opcao = lerEntradaSemVerificarLogin();

                if (opcao.equals("1")) {
                    throw new ReiniciarFormularioException();
                }

                if (opcao.equals("2")) {
                    throw new EncerrarAplicacaoException();
                }

                System.out.println("Opção inválida. Digite 1 ou 2.");
                System.out.print("Escolha uma opção: ");
            }
        }
    }

    private void executarFormulario(boolean autenticado) {

        RecomendacaoPedido request = preencherFormulario();

        Usuario usuario = autenticado
                ? autenticacaoService.getUsuarioAutenticado()
                : null;

        if (usuario != null) {
            request.setIdUsuario(usuario.getId_usuario());
        } else {
            request.setIdUsuario(null);
        }

        RecomendacaoResposta resposta = null;

        while (resposta == null) {

            try {

                resposta = recomendacaoService.recomendarFilmes(request);

            } catch (IllegalArgumentException e) {

                System.out.println("\nErro: " + e.getMessage());
                System.out.println("Preencha novamente as perguntas obrigatórias.");

                request = preencherFormulario();

                if (usuario != null) {
                    request.setIdUsuario(usuario.getId_usuario());
                }
            }
        }

        exibirRecomendacoes(resposta);

        boolean continuar = consultarFilmes(
                resposta.getFilmes(), usuario);

        if (!continuar) {
            throw new EncerrarAplicacaoException();
        }
    }

    private RecomendacaoPedido preencherFormulario() {

        RecomendacaoPedido request = new RecomendacaoPedido();

        List<String> generos = Arrays.asList(
                "Ação", "Aventura", "Comédia", "Drama",
                "Romance", "Terror", "Ficção", "Fantasia",
                "Animação", "Documentário", "Mistério", "Musical");

        List<String> duracoes = Arrays.asList(
                "Até 1h30", "1h30 - 2h", "2h - 3h", "3h+");

        List<String> streamings = Arrays.asList(
                "Netflix", "Prime Video", "Disney+",
                "HBO Max", "AppleTV", "GloboPlay");

        System.out.println("\n1. Quais gêneros você prefere?");
        request.setGenerosSelecionados(
                selecionarMultiplos(generos));

        System.out.println("\n2. Qual duração você prefere?");
        request.setDuracaoSelecionada(
                selecionarUnico(duracoes));

        System.out.println("\n3. Quais streamings você utiliza?");
        request.setStreamingSelecionados(
                selecionarMultiplos(streamings));

        while (true) {

            boolean formularioValido = true;

            if (request.getGenerosSelecionados() == null ||
                    request.getGenerosSelecionados().isEmpty()) {

                System.out.println(
                        "\nERRO: Selecione pelo menos um gênero.");

                System.out.println("1. Quais gêneros você prefere?");
                request.setGenerosSelecionados(
                        selecionarMultiplos(generos));

                formularioValido = false;
            }

            if (request.getDuracaoSelecionada() == null ||
                    request.getDuracaoSelecionada().isBlank()) {

                System.out.println(
                        "\nERRO: Selecione uma duração.");

                System.out.println("2. Qual duração você prefere?");
                request.setDuracaoSelecionada(
                        selecionarUnico(duracoes));

                formularioValido = false;
            }

            if (request.getStreamingSelecionados() == null ||
                    request.getStreamingSelecionados().isEmpty()) {

                System.out.println(
                        "\nERRO: Selecione pelo menos um streaming.");

                System.out.println("3. Quais streamings você utiliza?");
                request.setStreamingSelecionados(
                        selecionarMultiplos(streamings));

                formularioValido = false;
            }

            if (formularioValido) {
                break;
            }
        }

        System.out.println("\nDeseja responder às perguntas opcionais?");
        System.out.println("1 - Sim");
        System.out.println("2 - Não");

        String continuar;

        do {
            System.out.print("Escolha uma opção: ");
            continuar = lerEntrada();

            if (!continuar.equals("1") && !continuar.equals("2")) {
                System.out.println("Opção inválida. Digite 1 ou 2.");
            }

        } while (!continuar.equals("1") && !continuar.equals("2"));

        if (continuar.equals("1")) {

            List<String> classificacoes = Arrays.asList(
                    "Livre",
                    "Não recomendável para menores de 10 anos",
                    "Não recomendável para menores de 12 anos",
                    "Não recomendável para menores de 14 anos",
                    "Não recomendável para menores de 16 anos",
                    "Não recomendável para menores de 18 anos");

            List<String> paises = Arrays.asList(
                    "Argentina", "Brasil", "Canadá", "China",
                    "Coreia do Sul", "Estados Unidos", "França",
                    "Itália", "Japão", "Portugal");

            System.out.println(
                    "\n4. Qual classificação indicativa você prefere?");
            request.setClassificacaoSelecionada(
                    selecionarOpcional(classificacoes));

            System.out.println(
                    "\n5. De quais países você gostaria de assistir filmes?");
            request.setPaisesSelecionados(
                    selecionarMultiplosOpcional(paises));

            System.out.println(
                    "\n6. Deseja procurar filmes de algum ator ou diretor?");
            System.out.print(
                    "Digite o nome ou pressione ENTER para pular: ");

            request.setAtor(lerEntrada());

        } else {
            request.setClassificacaoSelecionada(null);
            request.setPaisesSelecionados(new ArrayList<>());
            request.setAtor("");
        }
        return request;
    }

    private void exibirOpcoes(List<String> opcoes) {
        for (int i = 0; i < opcoes.size(); i++) {
            System.out.println((i + 1) + " - " + opcoes.get(i));
        }
    }

    private List<String> selecionarMultiplos(List<String> opcoes) {
        exibirOpcoes(opcoes);
        System.out.print("Digite os números separados por vírgula ou ENTER para pular: ");
        String resposta = lerEntrada();
        if (resposta.isBlank()) {
            return new ArrayList<>();
        }
        try {
            return Arrays.stream(resposta.split(","))
                    .map(String::trim)
                    .map(Integer::parseInt)
                    .filter(numero -> numero >= 1 &&
                            numero <= opcoes.size())
                    .distinct()
                    .map(numero -> opcoes.get(numero - 1))
                    .toList();

        } catch (NumberFormatException e) {

            System.out.println("Digite números válidos.");
            return selecionarMultiplos(opcoes);
        }
    }

    private String selecionarUnico(List<String> opcoes) {

        exibirOpcoes(opcoes);

        System.out.print(
                "Digite o número da opção ou ENTER para pular: ");

        String resposta = lerEntrada();

        if (resposta.isBlank()) {
            return null;
        }
        try {
            int numero = Integer.parseInt(resposta);
            if (numero >= 1 && numero <= opcoes.size()) {
                return opcoes.get(numero - 1);
            }
        } catch (NumberFormatException e) {
            System.out.println("Digite um número válido.");
        }
        System.out.println("Opção inválida. Tente novamente.");

        return selecionarUnico(opcoes);
    }

    private String selecionarOpcional(List<String> opcoes) {
        exibirOpcoes(opcoes);
        System.out.print("Digite o número ou ENTER para pular: ");
        String resposta = lerEntrada();

        if (resposta.isBlank()) {
            return null;
        }

        try {
            int numero = Integer.parseInt(resposta);
            if (numero >= 1 && numero <= opcoes.size()) {
                return opcoes.get(numero - 1);
            }

        } catch (NumberFormatException e) {
            System.out.println("Resposta inválida. Pergunta ignorada.");
        }

        return null;
    }

    private List<String> selecionarMultiplosOpcional(List<String> opcoes) {
        exibirOpcoes(opcoes);
        System.out.print("Digite os números separados por vírgula ou ENTER para pular: ");
        String resposta = lerEntrada();

        if (resposta.isBlank()) {
            return new ArrayList<>();
        }

        try {

            return Arrays.stream(resposta.split(","))
                    .map(String::trim)
                    .map(Integer::parseInt)
                    .filter(numero -> numero >= 1 &&
                            numero <= opcoes.size())
                    .distinct()
                    .map(numero -> opcoes.get(numero - 1))
                    .toList();

        } catch (NumberFormatException e) {

            System.out.println("Resposta inválida. Pergunta ignorada.");
            return new ArrayList<>();
        }
    }

    private void exibirRecomendacoes(
            RecomendacaoResposta resposta) {

        System.out.println("\n===== FILMES RECOMENDADOS =====");
        System.out.println("Perfil: " + resposta.getPerfil());

        System.out.println(
                "Quantidade de sugestões: " + resposta.getQuantidade());

        int contador = 1;

        for (Filme filme : resposta.getFilmes()) {

            System.out.println("\n" + contador + " - "
                    + filme.getTitulo_filme());

            System.out.println("Nota: " + filme.getNota_filme());
            System.out.println("Duração: "
                    + filme.getDuracao_filme() + " minutos");

            contador++;
        }
    }

    private boolean consultarFilmes(
            List<Filme> filmes, Usuario usuario) {

        while (true) {

            System.out.println(
                    "\nDigite o número de um filme para ver suas informações.");

            System.out.println("0 - Encerrar");

            String resposta = lerEntrada();

            if (resposta.equals("0")) {
                System.out.println("\nMovieMatch finalizado.");
                return false;
            }

            try {

                int numero = Integer.parseInt(resposta);

                if (numero < 1 || numero > filmes.size()) {
                    System.out.println("Filme não encontrado.");
                    continue;
                }

                Filme filme = filmes.get(numero - 1);

                boolean voltarParaConsulta = false;

                while (!voltarParaConsulta) {

                    System.out.println("\n===== INFORMAÇÕES DO FILME =====");
                    System.out.println("Título: " + filme.getTitulo_filme());
                    System.out.println("Descrição: " + filme.getDescricao_filme());
                    System.out.println("Diretor: " + filme.getDiretor_filme());
                    System.out.println("Duração: " + filme.getDuracao_filme());
                    System.out.println("Streaming: " + filme.getStreaming_filme());
                    System.out.println("Nota: " + filme.getNota_filme());

                    System.out.println("\n===== OPÇÕES =====");
                    System.out.println("1 - Curtir filme");
                    System.out.println("2 - Adicionar filme a uma lista");
                    System.out.println("0 - Encerrar");
                    System.out.print("Escolha uma opção: ");

                    String opcao = lerEntrada();

                    switch (opcao) {

                        case "1":

                            if (usuario == null) {
                                usuario = obterUsuarioParaCurtir();
                            }

                            if (usuario == null) {
                                System.out.println(
                                        "Não foi possível realizar a curtida.");
                                break;
                            }

                            if (usuarioService.filmeJaCurtido(
                                    usuario.getId_usuario(),
                                    filme.getId_filme())) {

                                System.out.println(
                                        "Você já curtiu esse filme!");
                                break;
                            }

                            usuarioService.curtirFilme(
                                    usuario.getId_usuario(),
                                    filme.getId_filme());

                            System.out.println(
                                    "Filme curtido com sucesso!");

                            break;

                        case "2":

                            // Verifica se existe usuário autenticado.
                            if (usuario == null) {
                                usuario = obterUsuarioParaCurtir();
                            }

                            if (usuario == null) {
                                System.out.println(
                                        "Não foi possível adicionar o filme.");
                                break;
                            }

                            List<Lista> listas = listaService.buscarListasUsuario(
                                    usuario.getId_usuario());

                            if (listas == null || listas.isEmpty()) {

                                System.out.println(
                                        "\nVocê ainda não possui listas cadastradas.");

                                break;
                            }

                            System.out.println(
                                    "\nAdicionar \"" + filme.getTitulo_filme()
                                            + "\" em:");

                            for (int i = 0; i < listas.size(); i++) {

                                System.out.println(
                                        (i + 1) + " - "
                                                + listas.get(i).getNome_lista());
                            }

                            System.out.println("0 - Encerrar");
                            System.out.print("Escolha uma lista: ");

                            String escolhaLista = lerEntrada();

                            if (escolhaLista.equals("0")) {
                                System.out.println(
                                        "\nMovieMatch finalizado.");
                                throw new EncerrarAplicacaoException();
                            }

                            try {

                                int indice = Integer.parseInt(escolhaLista);

                                if (indice < 1 || indice > listas.size()) {

                                    System.out.println(
                                            "Lista inválida. Tente novamente.");

                                    break;
                                }

                                Lista listaEscolhida = listas.get(indice - 1);

                                listaService.adicionarFilme(
                                        listaEscolhida.getId_lista(),
                                        filme.getId_filme());

                                System.out.println(
                                        "\nFilme adicionado à lista \""
                                                + listaEscolhida.getNome_lista()
                                                + "\" com sucesso!");

                            } catch (NumberFormatException e) {

                                System.out.println(
                                        "Digite um número válido.");
                            }
                            break;

                        case "0":
                            System.out.println(
                                    "\nMovieMatch finalizado.");
                            throw new EncerrarAplicacaoException();
                        default:

                            System.out.println(
                                    "Opção inválida. Tente novamente.");
                    }
                }
            } catch (NumberFormatException e) {

                System.out.println("Digite um número válido.");
            }
        }
    }

    private Usuario obterUsuarioParaCurtir() {
        System.out.println("\n===== LOGIN =====");
        System.out.println(
                "Você precisa estar identificado para realizar esta operação.");
        System.out.print("Digite seu e-mail cadastrado: ");
        String email = lerEntrada();
        Usuario usuario = autenticacaoService.realizarLoginPorEmail(email);

        if (usuario == null) {
            System.out.println(
                    "Nenhuma conta encontrada com esse e-mail.");
            return null;
        }

        ultimaVersaoLogin = autenticacaoService.getVersaoLogin();

        System.out.println("\nIdentificação realizada com sucesso!");
        System.out.println("Bem-vindo, " + usuario.getNome_usuario() + "!");

        return usuario;
    }

}
