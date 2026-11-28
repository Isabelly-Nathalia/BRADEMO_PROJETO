
package com.brademobackend.moviematch.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecomendacaoPedido {

    private Long idUsuario;
    private List<String> generosSelecionados;
    private String duracaoSelecionada;
    private List<String> streamingSelecionados;
    private String classificacaoSelecionada;
    private List<String> paisesSelecionados;
    private String ator;
}
