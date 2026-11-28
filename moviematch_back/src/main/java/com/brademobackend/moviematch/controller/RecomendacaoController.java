
package com.brademobackend.moviematch.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.brademobackend.moviematch.model.RecomendacaoPedido;
import com.brademobackend.moviematch.model.RecomendacaoResposta;
import com.brademobackend.moviematch.service.RecomendacaoService;

@RestController
@RequestMapping("/recomendacoes")
@CrossOrigin
public class RecomendacaoController {

    @Autowired
    private RecomendacaoService recomendacaoService;

    @PostMapping
    public RecomendacaoResposta recomendar(
        @RequestBody RecomendacaoPedido request
    ) {
        return recomendacaoService.recomendarFilmes(request);
    }
}
