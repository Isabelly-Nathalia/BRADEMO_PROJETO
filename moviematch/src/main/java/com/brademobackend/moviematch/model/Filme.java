package com.brademobackend.moviematch.model;

import java.util.List;

import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Filme {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String titulo;
    private String descricao;
    private String diretor;
    private String imagemDiretor;
    private String atorEspecifico;
    private String nacionalidade;
    private String classificacao;
    private String streaming;
    private Float nota;
    private String linkImagemFilme;
    private Integer duracao;

    @ElementCollection
    private List<String> generos;
}