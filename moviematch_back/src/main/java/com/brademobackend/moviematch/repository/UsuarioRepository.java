package com.brademobackend.moviematch.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import com.brademobackend.moviematch.model.Usuario;

public interface UsuarioRepository extends CrudRepository<Usuario, Long> {

    @Query("""
                SELECT u
                FROM Usuario u
                WHERE u.email_usuario = :email
                AND u.senha_usuario = :senha
            """)
    Optional<Usuario> login(
            @Param("email") String email,
            @Param("senha") String senha);
}
