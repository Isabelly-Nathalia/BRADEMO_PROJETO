package com.brademobackend.moviematch.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.service.FilmeService;

@RestController
@RequestMapping("/filmes")
public class FilmeController {

    @Autowired
    private FilmeService filmeService;

    @GetMapping
    public Iterable<Filme> listarFilmes() {
        return filmeService.listarFilmes();
    }

    @GetMapping("/aleatorios")
    public List<Filme> buscarFilmesAleatorios() {
        return filmeService.buscarFilmesAleatorios();
    }

    @GetMapping("/streaming/{streaming}")
    public List<Filme> buscarPorStreaming(
            @PathVariable String streaming) {
        return filmeService.buscarPorStreaming(streaming);
    }

    @GetMapping("/streaming/outros")
    public List<Filme> buscarOutrosStreamings() {
        return filmeService.buscarOutrosStreamings();
    }
}