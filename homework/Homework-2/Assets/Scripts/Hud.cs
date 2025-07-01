using UnityEngine;

public class Hud : MonoBehaviour
{
    private int key_br;
    private int kruv_br;

    [SerializeField]
    int max_keys;

    [SerializeField]
    int max_kruvs;

    [SerializeField]
    SpriteRenderer[] keys;

    [SerializeField]
    SpriteRenderer[] kruvs;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        Zanuli();
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void Pokaji()
    {
        if (key_br < max_keys)
        {
            keys[key_br].enabled = true;
            key_br++;
        }
    }

    public void Narani()
    {
        if (kruv_br > 0)
        {
            kruv_br--;
            kruvs[kruv_br].enabled = false;
        }
    }

    public void Zanuli()
    {
        key_br = 0;
        for (int i = key_br; i < max_keys; i++)
        {
            keys[i].enabled = false;
        }

        kruv_br = max_kruvs;
        for (int i = 0; i < max_kruvs; i++)
        {
            kruvs[i].enabled = true;
        }
    }
}
