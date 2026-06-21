package com.brademobackend.moviematch.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.brademobackend.moviematch.model.Publicidade;
import com.brademobackend.moviematch.repository.PublicidadeRepository;

@Service
public class PublicidadeService {

    @Autowired
    private PublicidadeRepository publicidadeRepository;

    public Iterable<Publicidade> listarPublicidades() {
        return publicidadeRepository.findAll();
    }
}