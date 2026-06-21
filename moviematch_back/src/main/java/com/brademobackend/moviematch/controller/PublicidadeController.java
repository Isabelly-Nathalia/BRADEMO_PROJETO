package com.brademobackend.moviematch.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.brademobackend.moviematch.model.Publicidade;
import com.brademobackend.moviematch.service.PublicidadeService;

@RestController
@RequestMapping("/publicidades")
public class PublicidadeController {

    @Autowired
    private PublicidadeService publicidadeService;

    @GetMapping
    public Iterable<Publicidade> listarPublicidades() {
        return publicidadeService.listarPublicidades();
    }
}