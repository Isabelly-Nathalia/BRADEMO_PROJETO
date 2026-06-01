package com.brademobackend.moviematch.repository;

import org.springframework.data.repository.CrudRepository;
import com.brademobackend.moviematch.model.Filme;

public interface FilmeRepository extends CrudRepository<Filme, Long> {

}