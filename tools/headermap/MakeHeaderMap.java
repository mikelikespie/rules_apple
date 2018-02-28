package tools.headermap;

import com.facebook.buck.apple.clang.HeaderMap;
import com.google.common.base.Charsets;
import com.google.common.base.Preconditions;
import com.google.common.io.Files;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;

public class MakeHeaderMap {
  public static void main(String[] args) throws IOException {

    Preconditions.checkArgument(args.length == 2,
        "MakeHeaderMap requires two arguments. One input and one output");

    HeaderMap.Builder builder = HeaderMap.builder();

    List<String> lines = Files.readLines(new File(args[0]), Charsets.UTF_8);

    for (String line : lines) {
      String[] split = line.split(":", 2);
      Preconditions.checkState(split.length == 2);
      builder.add(split[0].trim(), Paths.get(split[1].trim()));
    }

    Files.write(builder.build().getBytes(), new File(args[1]));
  }
}
