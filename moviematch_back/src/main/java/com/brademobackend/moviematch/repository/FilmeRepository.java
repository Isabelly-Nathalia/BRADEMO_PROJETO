package com.brademobackend.moviematch.repository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import com.brademobackend.moviematch.model.Filme;

public interface FilmeRepository extends CrudRepository<Filme, Long> {

    @Query("""
            SELECT f
             FROM Filme f
             WHERE f.streaming_filme = :streaming
            """)
    List<Filme> buscarPorStreaming(
            @Param("streaming") String streaming);

    @Query("""

            SELECT f
            FROM Filme f
            WHERE f.streaming_filme NOT IN (
                'Netflix',
                'HBO Max',
                'Disney+',
                'Apple TV',
                'Globoplay',
                'Prime Video',
                'Tela Brasil')
            """)
    List<Filme> buscarOutrosStreamings();

    @Query("""
             SELECT f
             FROM Filme f
             WHERE LOWER(f.titulo_filme)
             LIKE LOWER(CONCAT('%', :titulo, '%'))
            """)
    List<Filme> pesquisarFilmes(
            @Param("titulo") String titulo);

}