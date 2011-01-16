module AccountHelper
  def label(name, obj, field)
    if obj.errors.on(field)
      haml_tag :p, {:class => 'type error'} do
        haml_concat name
        haml_tag :span, {:class => 'error'} do
          haml_concat "#{name} #{error_for(obj, field)}"
        end
      end
    else
      haml_tag :p, {:class => 'type'} do
        haml_concat name
      end
    end
  end
end
