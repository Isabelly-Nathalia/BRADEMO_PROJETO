package com.brademobackend.moviematch.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.brademobackend.moviematch.model.Lista;
import com.brademobackend.moviematch.service.ListaService;

@RestController
@RequestMapping("/listas")
public class ListaController {

    @Autowired
    private ListaService listaService;

    @PostMapping("/{idUsuario}")
    public Lista criarLista(@PathVariable Long idUsuario,@RequestBody Lista lista) {
        return listaService.criarLista(idUsuario, lista.getNome_lista());
    }

    @PostMapping("/{idLista}/filme/{idFilme}")
    public Lista adicionarFilme(@PathVariable Long idLista, @PathVariable Long idFilme) {
        return listaService.adicionarFilme(idLista, idFilme);
    }

    @GetMapping
    public Iterable<Lista> listarListas() {
        return listaService.listarListas();
    }
}