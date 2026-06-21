package com.brademobackend.moviematch.repository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import com.brademobackend.moviematch.model.Lista;

public interface ListaRepository extends CrudRepository<Lista, Long> {

        @Query("""
                        SELECT l
                        FROM Lista l
                        WHERE l.usuario.id_usuario = :idUsuario
                        """)
        List<Lista> buscarPorUsuario(
                        @Param("idUsuario") Long idUsuario);

        @Query("""
                        SELECT l
                        FROM Lista l
                        JOIN l.filmes f
                        WHERE l.usuario.id_usuario = :idUsuario
                        AND f.id_filme = :idFilme
                        """)
        List<Lista> buscarListasDoFilme(
                        @Param("idUsuario") Long idUsuario,
                        @Param("idFilme") Long idFilme);
}
