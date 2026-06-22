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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id_filme;
    private String titulo_filme;
    private String descricao_filme;
    private String imagemDiretor_filme;
    private Integer duracao_filme;
    private String streaming_filme;
    private String nacionalidade_filme;
    private String classificacao_filme;
    private String diretor_filme;
    private String linkImagemFilme_filme;
    private String atorEspecifico_filme;
    private double nota_filme;
    

    @ElementCollection
    private List<String> generos;
}