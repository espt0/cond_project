package validator

import (
	"reflect"
	"regexp"
	"strconv"
	"strings"
	"sync"

	"github.com/go-playground/validator/v10"
)

var (
	instance *validator.Validate
	once     sync.Once
)

func Get() *validator.Validate {
	once.Do(func() {
		instance = validator.New()

		// Usa o nome do campo json nas mensagens de erro
		instance.RegisterTagNameFunc(func(fld reflect.StructField) string {
			name := strings.SplitN(fld.Tag.Get("json"), ",", 2)[0]
			if name == "-" {
				return ""
			}
			return name
		})

		// Registra as validações customizadas
		instance.RegisterValidation("cpf", validateCPF)
		instance.RegisterValidation("cnpj", validateCNPJ)
	})
	return instance
}

// CNPJ
func validateCNPJ(fl validator.FieldLevel) bool {
	return isValidCNPJ(fl.Field().String())
}

func isValidCNPJ(cnpj string) bool {
	// Remove formatação (pontos, barra e traço)
	cnpj = regexp.MustCompile(`\D`).ReplaceAllString(cnpj, "")

	if len(cnpj) != 14 {
		return false
	}

	// Rejeita CNPJs com todos os dígitos iguais (ex: 00000000000000)
	allSame := true
	for _, c := range cnpj {
		if c != rune(cnpj[0]) {
			allSame = false
			break
		}
	}
	if allSame {
		return false
	}

	// Calcula o primeiro dígito verificador
	// Os pesos ciclam: 5,4,3,2,9,8,7,6,5,4,3,2 para os 12 primeiros dígitos
	weights1 := []int{5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2}
	sum := 0
	for i, w := range weights1 {
		digit, _ := strconv.Atoi(string(cnpj[i]))
		sum += digit * w
	}
	remainder := sum % 11
	first := 0
	if remainder >= 2 {
		first = 11 - remainder
	}

	if strconv.Itoa(first) != string(cnpj[12]) {
		return false
	}

	// Calcula o segundo dígito verificador
	// Os pesos ciclam: 6,5,4,3,2,9,8,7,6,5,4,3,2 para os 13 primeiros dígitos
	weights2 := []int{6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2}
	sum = 0
	for i, w := range weights2 {
		digit, _ := strconv.Atoi(string(cnpj[i]))
		sum += digit * w
	}
	remainder = sum % 11
	second := 0
	if remainder >= 2 {
		second = 11 - remainder
	}

	return strconv.Itoa(second) == string(cnpj[13])
}

// CPF
func validateCPF(fl validator.FieldLevel) bool {
	return isValidCPF(fl.Field().String())
}

func isValidCPF(cpf string) bool {
	// Remove qualquer formatação (pontos e traço)
	cpf = regexp.MustCompile(`\D`).ReplaceAllString(cpf, "")

	// Deve ter exatamente 11 dígitos
	if len(cpf) != 11 {
		return false
	}

	// CPFs com todos os dígitos iguais são inválidos (ex: 111.111.111-11)
	// mas passariam no algoritmo — precisamos rejeitar explicitamente
	allSame := true
	for _, c := range cpf {
		if c != rune(cpf[0]) {
			allSame = false
			break
		}
	}
	if allSame {
		return false
	}

	// Calcula o primeiro dígito verificador
	// Pesos: 10, 9, 8, 7, 6, 5, 4, 3, 2 (para os 9 primeiros dígitos)
	sum := 0
	for i := 0; i < 9; i++ {
		digit, _ := strconv.Atoi(string(cpf[i]))
		sum += digit * (10 - i)
	}
	remainder := sum % 11
	first := 0
	if remainder >= 2 {
		first = 11 - remainder
	}

	// O 10º dígito do CPF deve ser igual ao que calculamos
	if strconv.Itoa(first) != string(cpf[9]) {
		return false
	}

	// Calcula o segundo dígito verificador
	// Pesos: 11, 10, 9, 8, 7, 6, 5, 4, 3, 2 (para os 10 primeiros dígitos)
	sum = 0
	for i := 0; i < 10; i++ {
		digit, _ := strconv.Atoi(string(cpf[i]))
		sum += digit * (11 - i)
	}
	remainder = sum % 11
	second := 0
	if remainder >= 2 {
		second = 11 - remainder
	}

	// O 11º dígito do CPF deve ser igual ao que calculamos
	return strconv.Itoa(second) == string(cpf[10])
}
