package com.brademobackend.moviematch.model;

import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToMany;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id_usuario;
    private String nome_usuario;
    private String email_usuario;
    private String nomeDeUsuario_usuario;
    private String senha_usuario;
    private String fotoPerfil_usuario; //salva o caminho da imagem
    private LocalDate dataNascimento_usuario;

    @ManyToMany
    private List<Filme> filmesCurtidos;
}