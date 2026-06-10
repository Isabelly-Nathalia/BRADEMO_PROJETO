package com.brademobackend.moviematch.service;

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

    public List<Filme> buscarFilmesAleatorios() {
        List<Filme> filmes = (List<Filme>) filmeRepository.findAll();
        Collections.shuffle(filmes);
        return filmes.stream()
                .limit(5)
                .toList();
    }

    public List<Filme> buscarPorStreaming(String streaming) {
        return filmeRepository.buscarPorStreaming(streaming);
    }

    public List<Filme> buscarOutrosStreamings() {
        return filmeRepository.buscarOutrosStreamings();
    }

}