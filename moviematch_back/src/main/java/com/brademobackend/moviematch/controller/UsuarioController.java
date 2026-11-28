package com.brademobackend.moviematch.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.brademobackend.moviematch.model.Filme;
import com.brademobackend.moviematch.model.Usuario;
import com.brademobackend.moviematch.service.UsuarioService;
import com.brademobackend.moviematch.service.AutenticacaoService;

@RestController
@RequestMapping("/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private AutenticacaoService autenticacaoService;

    @PostMapping
    public Usuario criarUsuario(@RequestBody Usuario usuario) {
        return usuarioService.salvarUsuario(usuario);
    }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Usuario usuario) {

        Usuario usuarioAutenticado =
                autenticacaoService.realizarLogin(
                        usuario.getEmail_usuario(),
                        usuario.getSenha_usuario()
                );

        if (usuarioAutenticado == null) {
            throw new RuntimeException("E-mail ou senha inválidos.");
        }

        Map<String, Object> resposta = new HashMap<>();

        resposta.put("mensagem", "Login realizado com sucesso.");
        resposta.put("id_usuario", usuarioAutenticado.getId_usuario());
        resposta.put("nome_usuario", usuarioAutenticado.getNome_usuario());
        resposta.put("email_usuario", usuarioAutenticado.getEmail_usuario());

        return resposta;
    }

    @PostMapping("/logout")
    public String logout() {
        autenticacaoService.realizarLogout();
        return "Logout realizado com sucesso.";
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
    public Usuario curtirFilme(
            @PathVariable Long idUsuario,
            @PathVariable Long idFilme) {

        return usuarioService.curtirFilme(idUsuario, idFilme);
    }

    @GetMapping("/{idUsuario}/curtidos")
    public List<Filme> buscarCurtidos(@PathVariable Long idUsuario) {
        return usuarioService.buscarCurtidos(idUsuario);
    }

    @GetMapping("/{idUsuario}/curtiu/{idFilme}")
    public boolean filmeJaCurtido(
            @PathVariable Long idUsuario,
            @PathVariable Long idFilme) {

        return usuarioService.filmeJaCurtido(idUsuario, idFilme);
    }

    @DeleteMapping("/{idUsuario}/curtir/{idFilme}")
    public Usuario removerCurtida(
            @PathVariable Long idUsuario,
            @PathVariable Long idFilme) {

        return usuarioService.removerCurtida(idUsuario, idFilme);
    }
}