package com.brademobackend.moviematch.service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.stream.StreamSupport;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.model.RecomendacaoPedido;
import com.brademobackend.moviematch.model.RecomendacaoResposta;
import com.brademobackend.moviematch.model.Usuario;
import com.brademobackend.moviematch.repository.FilmeRepository;
import com.brademobackend.moviematch.repository.UsuarioRepository;
import org.springframework.transaction.annotation.Transactional;


@Service
public class RecomendacaoService {

    @Autowired
    private FilmeRepository filmeRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    public void validarFormulario(RecomendacaoPedido request) {

        if (request.getGenerosSelecionados() == null ||
                request.getGenerosSelecionados().isEmpty()) {
            throw new IllegalArgumentException(
                    "Selecione pelo menos um gênero.");
        }

        if (request.getDuracaoSelecionada() == null ||
                request.getDuracaoSelecionada().isBlank()) {
            throw new IllegalArgumentException(
                    "Selecione uma duração.");
        }

        if (request.getStreamingSelecionados() == null ||
                request.getStreamingSelecionados().isEmpty()) {
            throw new IllegalArgumentException(
                    "Selecione pelo menos um streaming.");
        }
    }

    public String identificarPerfil(Usuario usuario) {
        LocalDate dataCriacao = usuario.getDataCriacaoConta_usuario().toLocalDate();
        long dias = ChronoUnit.DAYS.between(
                dataCriacao, LocalDate.now());

        if (dias < 90) {
            return "Curtidor Leve";
        } else if (dias < 365) {
            return "Entusiasta";
        } else {
            return "Cinéfilo Apaixonado";
        }
    }

    public int definirQuantidade(String perfil) {
        switch (perfil) {
            case "Curtidor Leve":
                return 4;
            case "Entusiasta":
                return 6;
            case "Cinéfilo Apaixonado":
                return 8;
            default:
                return 3;
        }
    }

    public int calcularPontuacao(Filme filme, RecomendacaoPedido request) {
        int pontuacao = 0;
        if (filme.getGeneros() != null &&
                filme.getGeneros().stream()
                        .anyMatch(request.getGenerosSelecionados()::contains)) {
            pontuacao += 3;
        }

        Integer duracao = filme.getDuracao_filme();
        if (duracao != null) {
            if (request.getDuracaoSelecionada().equals("Até 1h30")
                    && duracao <= 90) {
                pontuacao += 2;
            } else if (request.getDuracaoSelecionada().equals("1h30 - 2h")
                    && duracao > 90 && duracao <= 120) {
                pontuacao += 2;

            } else if (request.getDuracaoSelecionada().equals("2h - 3h")
                    && duracao > 120 && duracao <= 180) {
                pontuacao += 2;

            } else if (request.getDuracaoSelecionada().equals("3h+")
                    && duracao > 180) {
                pontuacao += 2;
            }
        }

        if (request.getStreamingSelecionados()
                .contains(filme.getStreaming_filme())) {
            pontuacao += 3;
        }

        if (request.getClassificacaoSelecionada() != null &&
                request.getClassificacaoSelecionada()
                        .equals(filme.getClassificacao_filme())) {
            pontuacao += 2;
        }

        if (request.getPaisesSelecionados() != null &&
                request.getPaisesSelecionados()
                        .contains(filme.getNacionalidade_filme())) {
            pontuacao += 1;
        }

        if (request.getAtor() != null &&
                !request.getAtor().isBlank()) {
            String busca = request.getAtor().toLowerCase();
            boolean encontrouDiretor = filme.getDiretor_filme() != null &&
                    filme.getDiretor_filme()
                            .toLowerCase().contains(busca);
            boolean encontrouAtor = filme.getAtorEspecifico_filme() != null &&
                    filme.getAtorEspecifico_filme()
                            .toLowerCase().contains(busca);
            if (encontrouDiretor || encontrouAtor) {
                pontuacao += 1;
            }
        }

        return pontuacao;
    }

    @Transactional(readOnly = true)
    public RecomendacaoResposta recomendarFilmes(RecomendacaoPedido request) {
        validarFormulario(request);

        Usuario usuario = null;

        if (request.getIdUsuario() != null) {
            usuario = usuarioRepository
                    .findById(request.getIdUsuario())
                    .orElse(null);
        }

        String perfil;
        int quantidade;

        if (usuario == null) {
            perfil = "Visitante";
            quantidade = 3;
        } else {
            perfil = identificarPerfil(usuario);
            quantidade = definirQuantidade(perfil);
        }

        List<Filme> filmes = StreamSupport
                .stream(filmeRepository.findAll().spliterator(), false)
                .toList();

        List<Filme> recomendados = filmes.stream()
                .sorted(Comparator.comparingInt(
                        (Filme filme) -> calcularPontuacao(filme, request))
                        .reversed())
                .limit(quantidade)
                .toList();

        return new RecomendacaoResposta(
                perfil, quantidade, recomendados);
    }
}