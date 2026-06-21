package com.brademobackend.moviematch.model;

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
public class Publicidade {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id_publicidade;
    private String descricao;
    private String link_imagem;
}