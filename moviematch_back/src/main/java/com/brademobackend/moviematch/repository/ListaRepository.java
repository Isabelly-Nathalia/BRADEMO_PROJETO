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
}
