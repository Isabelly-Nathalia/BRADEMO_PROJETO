package com.brademobackend.moviematch.service;

import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.brademobackend.moviematch.model.Usuario;
import com.brademobackend.moviematch.repository.UsuarioRepository;

@Service
public class AutenticacaoService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    private volatile Usuario usuarioAutenticado;
    private final AtomicLong versaoLogin = new AtomicLong(0);

    public Usuario realizarLogin(String email, String senha) {

        Optional<Usuario> usuario = usuarioRepository.login(email, senha);

        if (usuario.isPresent()) {
            usuarioAutenticado = usuario.get();
            versaoLogin.incrementAndGet();
        }

        return usuario.orElse(null);
    }

    public Usuario realizarLoginPorEmail(String email) {
        Optional<Usuario> usuario = usuarioRepository.buscarPorEmail(email);

        if (usuario.isPresent()) {
            usuarioAutenticado = usuario.get();
            versaoLogin.incrementAndGet();
        }
        return usuario.orElse(null);
    }

    public Usuario getUsuarioAutenticado() {
        return usuarioAutenticado;
    }

    public long getVersaoLogin() {
        return versaoLogin.get();
    }

    public void realizarLogout() {
        usuarioAutenticado = null;
    }
}