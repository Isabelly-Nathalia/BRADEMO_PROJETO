package com.brademobackend.moviematch;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication
public class MoviematchApplication {

    public static void main(String[] args) {

    ConfigurableApplicationContext contexto =
            SpringApplication.run(
                    MoviematchApplication.class, args);

    FormularioTerminal formulario =
            contexto.getBean(FormularioTerminal.class);

    boolean continuar = formulario.executar();

    if (!continuar) {
        contexto.close();
    }
}
}