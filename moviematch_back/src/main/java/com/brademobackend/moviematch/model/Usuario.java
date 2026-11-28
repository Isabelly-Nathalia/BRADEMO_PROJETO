package com.brademobackend.moviematch.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.PrePersist;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id_usuario;
    private String nome_usuario;
    private String email_usuario;
    private String nomeDeUsuario_usuario;
    private String senha_usuario;
    private String fotoPerfil_usuario; 
    private LocalDate dataNascimento_usuario;
    private LocalDateTime dataCriacaoConta_usuario;

    
    @ManyToMany
    @JoinTable(name = "usuario_filmes_curtidos", joinColumns = @JoinColumn(name = "usuario_fk"), inverseJoinColumns = @JoinColumn(name = "filme_fk"))
    private List<Filme> filmesCurtidos;

     @PrePersist
    public void definirDataCriacaoConta() {
        if (dataCriacaoConta_usuario == null) {
            dataCriacaoConta_usuario = LocalDateTime.now();
        }
    }
    
}