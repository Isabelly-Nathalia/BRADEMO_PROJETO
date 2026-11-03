package com.brademobackend.moviematch.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.repository.FilmeRepository;

@Service
public class FilmeService {

    @Autowired
    private FilmeRepository filmeRepository;

    public Iterable<Filme> listarFilmes() {
        return filmeRepository.findAll();
    }

    public List<Filme> buscarFilmesAleatorios(int quantidade) {
    List<Filme> filmes = new ArrayList<>();
    filmeRepository.findAll().forEach(filmes::add);
    Collections.shuffle(filmes);
    return filmes.stream().limit(Math.max(0, Math.min(quantidade, filmes.size()))).toList();
}

    public List<Filme> buscarPorStreaming(String streaming) {
        return filmeRepository.buscarPorStreaming(streaming);
    }

    public List<Filme> buscarOutrosStreamings() {
        return filmeRepository.buscarOutrosStreamings();
    }

    public List<Filme> pesquisarFilmes(String titulo) {
        return filmeRepository.pesquisarFilmes(titulo);
    }
}