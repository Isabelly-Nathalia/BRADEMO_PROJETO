package com.brademobackend.moviematch.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.model.Lista;
import com.brademobackend.moviematch.model.Usuario;
import com.brademobackend.moviematch.repository.UsuarioRepository;
import com.brademobackend.moviematch.repository.FilmeRepository;
import com.brademobackend.moviematch.repository.ListaRepository;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private FilmeRepository filmeRepository;

    @Autowired
    private ListaRepository listaRepository;

    public Usuario salvarUsuario(Usuario usuario) {
        return usuarioRepository.save(usuario);
    }

    public Iterable<Usuario> listarUsuarios() {
        return usuarioRepository.findAll();
    }

    public Optional<Usuario> buscarUsuarioPorId(Long id) {
        return usuarioRepository.findById(id);
    }

    public Usuario atualizarUsuario(Usuario usuario) {
        return usuarioRepository.save(usuario);
    }

    public void deletarUsuario(Long id) {
        List<Lista> listas = listaRepository.buscarPorUsuario(id);
        listaRepository.deleteAll(listas);
        usuarioRepository.deleteById(id);
    }

    public Usuario login(String email, String senha) {
        Optional<Usuario> usuario = usuarioRepository.login(email, senha);
        return usuario.orElse(null);
    }

    public Usuario curtirFilme(Long idUsuario, Long idFilme) {
        Usuario usuario = usuarioRepository.findById(idUsuario).orElseThrow();
        Filme filme = filmeRepository.findById(idFilme).orElseThrow();
        boolean jaCurtido = usuario.getFilmesCurtidos().stream().anyMatch(f -> f.getId_filme().equals(idFilme));
        if (!jaCurtido) {
            usuario.getFilmesCurtidos().add(filme);
        }
        return usuarioRepository.save(usuario);
    }

    public List<Filme> buscarCurtidos(Long idUsuario) {
        Usuario usuario = usuarioRepository.findById(idUsuario).orElseThrow();
        return usuario.getFilmesCurtidos();
    }

    public boolean filmeJaCurtido(Long idUsuario, Long idFilme) {
        Usuario usuario = usuarioRepository.findById(idUsuario).orElseThrow();
        return usuario.getFilmesCurtidos().stream().anyMatch(f -> f.getId_filme().equals(idFilme));
    }

    public Usuario removerCurtida(Long idUsuario, Long idFilme) {
        Usuario usuario = usuarioRepository.findById(idUsuario).orElseThrow();
        usuario.getFilmesCurtidos().removeIf(filme -> filme.getId_filme().equals(idFilme));
        return usuarioRepository.save(usuario);
    }
}
