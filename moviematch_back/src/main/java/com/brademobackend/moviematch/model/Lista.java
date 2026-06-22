package com.brademobackend.moviematch.model;

import java.util.List;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Lista {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id_lista;
    private String nome_lista;

    @ManyToOne
    @JoinColumn(name = "usuario_fk")
    private Usuario usuario;

    @ManyToMany
    @JoinTable(name = "lista_filmes", joinColumns = @JoinColumn(name = "lista_fk"), inverseJoinColumns = @JoinColumn(name = "filme_fk"))
    private List<Filme> filmes;
}