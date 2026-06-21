package com.brademobackend.moviematch.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.model.Lista;
import com.brademobackend.moviematch.model.Usuario;
import com.brademobackend.moviematch.repository.FilmeRepository;
import com.brademobackend.moviematch.repository.ListaRepository;
import com.brademobackend.moviematch.repository.UsuarioRepository;

@Service
public class ListaService {

    @Autowired
    private ListaRepository listaRepository;
    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private FilmeRepository filmeRepository;

    public Lista criarLista(Long idUsuario, String nomeLista) {
        Usuario usuario = usuarioRepository.findById(idUsuario).orElseThrow();
        Lista lista = new Lista();
        lista.setNome_lista(nomeLista);
        lista.setUsuario(usuario);
        return listaRepository.save(lista);
    }

    public Lista adicionarFilme(Long idLista, Long idFilme) {
        Lista lista = listaRepository.findById(idLista).orElseThrow();
        Filme filme = filmeRepository.findById(idFilme).orElseThrow();

        boolean jaExiste = lista.getFilmes().stream().anyMatch(f -> f.getId_filme().equals(idFilme));
        if (!jaExiste) {
            lista.getFilmes().add(filme);
        }
        return listaRepository.save(lista);
    }

    public Iterable<Lista> listarListas() {
        return listaRepository.findAll();
    }

    public List<Lista> buscarListasUsuario(Long idUsuario) {
        return listaRepository.buscarPorUsuario(idUsuario);
    }

    public List<Lista> buscarListasDoFilme(Long idUsuario, Long idFilme) {
        return listaRepository.buscarListasDoFilme(idUsuario, idFilme);
    }

    public Lista removerFilme(Long idLista, Long idFilme) {
        Lista lista = listaRepository.findById(idLista).orElseThrow();
        lista.getFilmes().removeIf(filme -> filme.getId_filme().equals(idFilme));
        return listaRepository.save(lista);
    }

    public Lista editarLista(Long idLista, String nomeLista) {
        Lista lista = listaRepository.findById(idLista).orElseThrow();
        lista.setNome_lista(nomeLista);
        return listaRepository.save(lista);
    }

    public void excluirLista(Long idLista) {
        listaRepository.deleteById(idLista);
    }
}