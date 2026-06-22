package com.brademobackend.moviematch.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import java.util.Optional;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import java.util.List;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.model.Usuario;
import com.brademobackend.moviematch.service.UsuarioService;

@RestController
@RequestMapping("/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping
    public Usuario criarUsuario(@RequestBody Usuario usuario) {
        return usuarioService.salvarUsuario(usuario);
    }

    @PostMapping("/login")
    public Usuario login(@RequestBody Usuario usuario) {
        return usuarioService.login(
                usuario.getEmail_usuario(),
                usuario.getSenha_usuario());
    }

    @GetMapping
    public Iterable<Usuario> listarUsuarios() {
        return usuarioService.listarUsuarios();
    }

    @GetMapping("/{id}")
    public Optional<Usuario> buscarUsuario(@PathVariable Long id) {
        return usuarioService.buscarUsuarioPorId(id);
    }

    @PutMapping("/{id}")
    public Usuario atualizarUsuario(
            @PathVariable Long id,
            @RequestBody Usuario usuario) {

        usuario.setId_usuario(id);

        return usuarioService.atualizarUsuario(usuario);
    }

    @DeleteMapping("/{id}")
    public void deletarUsuario(@PathVariable Long id) {
        usuarioService.deletarUsuario(id);
    }

    @PostMapping("/{idUsuario}/curtir/{idFilme}")
    public Usuario curtirFilme(@PathVariable Long idUsuario, @PathVariable Long idFilme) {
        return usuarioService.curtirFilme(idUsuario, idFilme);
    }

    @GetMapping("/{idUsuario}/curtidos")
    public List<Filme> buscarCurtidos(@PathVariable Long idUsuario) {
        return usuarioService.buscarCurtidos(idUsuario);
    }

    @GetMapping("/{idUsuario}/curtiu/{idFilme}")
    public boolean filmeJaCurtido(@PathVariable Long idUsuario, @PathVariable Long idFilme) {
        return usuarioService.filmeJaCurtido(idUsuario, idFilme);
    }

    @DeleteMapping("/{idUsuario}/curtir/{idFilme}")
    public Usuario removerCurtida(@PathVariable Long idUsuario, @PathVariable Long idFilme) {
        return usuarioService.removerCurtida(idUsuario, idFilme);
    }
}