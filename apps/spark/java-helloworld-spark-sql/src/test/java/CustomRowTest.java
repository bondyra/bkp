import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class CustomRowTest {

    @Test
    public void testCustomRow() {
        CustomRow customRow = new CustomRow("name", 12);

        assertThat(customRow.getAge()).isEqualTo(12);
        assertThat(customRow.getName()).isEqualTo("name");

        customRow.setAge(11);
        assertThat(customRow.getAge()).isEqualTo(11);
        assertThat(customRow.getName()).isEqualTo("name");

        customRow.setName("a");
        assertThat(customRow.getAge()).isEqualTo(1);
        assertThat(customRow.getName()).isEqualTo("a");
    }

}
